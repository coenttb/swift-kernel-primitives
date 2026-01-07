// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Binary

extension Kernel {
    /// File locking types and operations.
    public enum Lock {}
}

// MARK: - Error Mapping

#if os(Windows)
    public import WinSDK
#endif

extension Kernel.Lock.Error {
    /// Creates a lock error from a platform error code.
    @inlinable
    init(_ code: Kernel.Error.Code) {
        switch code {
        case .posix(let errno):
            #if !os(Windows)
                switch errno {
                case EDEADLK:
                    self = .deadlock
                case ENOLCK:
                    self = .unavailable
                default:
                    // EAGAIN/EACCES are handled in tryLock, shouldn't reach here
                    self = .contention
                }
            #else
                self = .contention
            #endif

        case .win32(let error):
            #if os(Windows)
                switch DWORD(error) {
                case DWORD(ERROR_LOCK_VIOLATION), DWORD(ERROR_SHARING_VIOLATION), DWORD(ERROR_LOCK_FAILED):
                    self = .contention
                default:
                    self = .unavailable
                }
            #else
                self = .unavailable
            #endif
        }
    }
}

// MARK: - POSIX Implementation

#if !os(Windows)

    #if canImport(Darwin)
        public import Darwin
    #elseif canImport(Glibc)
        public import Glibc
        public import CLinuxShim
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Lock {
        /// Acquires a lock on a byte range (blocking).
        ///
        /// This call blocks until the lock can be acquired.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor.
        ///   - range: The byte range to lock.
        ///   - kind: The lock kind (shared or exclusive).
        /// - Throws: `Error.deadlock` if a deadlock is detected,
        ///           `Error.unavailable` if the system lock table is exhausted.
        @inlinable
        public static func lock(
            _ descriptor: Kernel.Descriptor,
            range: Range,
            kind: Kind
        ) throws(Kernel.Lock.Error) {
            var fl = makeFlock(range: range, kind: kind)

            let result = fcntl(descriptor.rawValue, F_SETLKW, &fl)
            guard result != -1 else {
                throw Error(.captureErrno())
            }
        }

        /// Attempts to acquire a lock without blocking.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor.
        ///   - range: The byte range to lock.
        ///   - kind: The lock kind (shared or exclusive).
        /// - Returns: `true` if the lock was acquired, `false` if it would block.
        /// - Throws: `Error.deadlock` if a deadlock is detected,
        ///           `Error.unavailable` if the system lock table is exhausted.
        @inlinable
        public static func tryLock(
            _ descriptor: Kernel.Descriptor,
            range: Range,
            kind: Kind
        ) throws(Kernel.Lock.Error) -> Bool {
            var fl = makeFlock(range: range, kind: kind)

            let result = fcntl(descriptor.rawValue, F_SETLK, &fl)
            if result == -1 {
                // EAGAIN or EACCES means the lock is held by another process
                if errno == EAGAIN || errno == EACCES {
                    return false
                }
                throw Error(.captureErrno())
            }
            return true
        }

        /// Releases a lock on a byte range.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor.
        ///   - range: The byte range to unlock.
        /// - Throws: `Error` if unlocking fails.
        @inlinable
        public static func unlock(
            _ descriptor: Kernel.Descriptor,
            range: Range
        ) throws(Kernel.Lock.Error) {
            var fl = flock()
            fl.l_type = Int16(F_UNLCK)
            fl.l_whence = Int16(SEEK_SET)

            switch range {
            case .file:
                fl.l_start = 0
                fl.l_len = 0  // 0 means lock to EOF
            case .bytes(let start, let end):
                fl.l_start = off_t(start.rawValue)
                fl.l_len = off_t((end - start).rawValue)
            }

            let result = fcntl(descriptor.rawValue, F_SETLK, &fl)
            guard result != -1 else {
                throw Error(.captureErrno())
            }
        }

        /// Creates a flock structure for fcntl.
        @inlinable
        static func makeFlock(range: Range, kind: Kind) -> flock {
            var fl = flock()

            fl.l_type = kind == .shared ? Int16(F_RDLCK) : Int16(F_WRLCK)
            fl.l_whence = Int16(SEEK_SET)

            switch range {
            case .file:
                // l_start = 0, l_len = 0 means "lock entire file to EOF"
                fl.l_start = 0
                fl.l_len = 0
            case .bytes(let start, let end):
                fl.l_start = off_t(start.rawValue)
                fl.l_len = off_t((end - start).rawValue)
            }

            return fl
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)

    extension Kernel.Lock {
        /// Acquires a lock on a byte range (blocking).
        ///
        /// This call blocks until the lock can be acquired.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor (Windows HANDLE).
        ///   - range: The byte range to lock.
        ///   - kind: The lock kind (shared or exclusive).
        /// - Throws: `Error.unavailable` on failure.
        @inlinable
        public static func lock(
            _ descriptor: Kernel.Descriptor,
            range: Range,
            kind: Kind
        ) throws(Kernel.Lock.Error) {
            var overlapped = makeOverlapped(range: range)
            let (lengthLow, lengthHigh) = lockLength(range: range)

            // For blocking, don't use LOCKFILE_FAIL_IMMEDIATELY
            let flags: DWORD = kind == .exclusive ? DWORD(LOCKFILE_EXCLUSIVE_LOCK) : 0

            let result = LockFileEx(
                descriptor.rawValue,
                flags,
                0,
                lengthLow,
                lengthHigh,
                &overlapped
            )

            guard result else {
                throw Error(.captureLastError())
            }
        }

        /// Attempts to acquire a lock without blocking.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor (Windows HANDLE).
        ///   - range: The byte range to lock.
        ///   - kind: The lock kind (shared or exclusive).
        /// - Returns: `true` if the lock was acquired, `false` if it would block.
        /// - Throws: `Error` on failure other than contention.
        @inlinable
        public static func tryLock(
            _ descriptor: Kernel.Descriptor,
            range: Range,
            kind: Kind
        ) throws(Kernel.Lock.Error) -> Bool {
            var overlapped = makeOverlapped(range: range)
            let (lengthLow, lengthHigh) = lockLength(range: range)

            var flags: DWORD = DWORD(LOCKFILE_FAIL_IMMEDIATELY)
            if kind == .exclusive {
                flags |= DWORD(LOCKFILE_EXCLUSIVE_LOCK)
            }

            let result = LockFileEx(
                descriptor.rawValue,
                flags,
                0,
                lengthLow,
                lengthHigh,
                &overlapped
            )

            if !result {
                let error = GetLastError()
                if error == DWORD(ERROR_LOCK_VIOLATION) || error == DWORD(ERROR_LOCK_FAILED) {
                    return false
                }
                throw Error(.win32(UInt32(error)))
            }
            return true
        }

        /// Releases a lock on a byte range.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor (Windows HANDLE).
        ///   - range: The byte range to unlock.
        /// - Throws: `Error` if unlocking fails.
        @inlinable
        public static func unlock(
            _ descriptor: Kernel.Descriptor,
            range: Range
        ) throws(Kernel.Lock.Error) {
            var overlapped = makeOverlapped(range: range)
            let (lengthLow, lengthHigh) = lockLength(range: range)

            let result = UnlockFileEx(
                descriptor.rawValue,
                0,
                lengthLow,
                lengthHigh,
                &overlapped
            )

            guard result else {
                throw Error(.captureLastError())
            }
        }

        /// Creates an OVERLAPPED structure for the given range.
        @inlinable
        static func makeOverlapped(range: Range) -> OVERLAPPED {
            var overlapped = OVERLAPPED()
            let start: Int64
            switch range {
            case .file:
                start = 0
            case .bytes(let s, _):
                start = s.rawValue
            }
            overlapped.Offset = DWORD(UInt64(bitPattern: start) & 0xFFFF_FFFF)
            overlapped.OffsetHigh = DWORD(UInt64(bitPattern: start) >> 32)
            return overlapped
        }

        /// Computes the DWORD pair for the lock length.
        ///
        /// Windows LockFileEx locks exact byte counts (unlike POSIX's "to EOF" with l_len=0).
        @inlinable
        static func lockLength(range: Range) -> (low: DWORD, high: DWORD) {
            switch range {
            case .file:
                // Use max DWORD values to lock the largest possible range from offset 0.
                // This is the Windows equivalent of "lock entire file".
                return (DWORD.max, DWORD.max)
            case .bytes(let start, let end):
                let length = UInt64(bitPattern: (end - start).rawValue)
                return (DWORD(length & 0xFFFF_FFFF), DWORD(length >> 32))
            }
        }
    }

#endif
