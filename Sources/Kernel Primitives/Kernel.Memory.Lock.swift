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

extension Kernel.Memory {
    /// Raw page locking syscall wrappers.
    ///
    /// Provides policy-free access to mlock/munlock (cross-platform) and
    /// VirtualLock/VirtualUnlock (Windows).
    ///
    /// For mlockall/munlockall (POSIX-only), see `POSIX.Kernel.Memory.Lock` in swift-posix.
    public enum Lock {}
}

// MARK: - POSIX Implementation

#if !os(Windows)

    #if canImport(Darwin)
        public import Darwin
    #elseif canImport(Glibc)
        public import Glibc
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Memory.Lock {
        /// Locks pages in memory, preventing them from being swapped.
        ///
        /// - Parameters:
        ///   - address: The starting address of the memory range.
        ///   - length: The number of bytes to lock.
        /// - Throws: `Error.lock` on failure.
        @inlinable
        public static func lock(address: UnsafeRawPointer, length: Kernel.File.Size) throws(Error) {
            guard mlock(address, Int(length)) == 0 else {
                throw .lock(.captureErrno())
            }
        }

        /// Unlocks pages in memory, allowing them to be swapped.
        ///
        /// - Parameters:
        ///   - address: The starting address of the memory range.
        ///   - length: The number of bytes to unlock.
        /// - Throws: `Error.unlock` on failure.
        @inlinable
        public static func unlock(address: UnsafeRawPointer, length: Kernel.File.Size) throws(Error) {
            guard munlock(address, Int(length)) == 0 else {
                throw .unlock(.captureErrno())
            }
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)

    public import WinSDK

    extension Kernel.Memory.Lock {
        /// Locks pages in memory, preventing them from being swapped.
        ///
        /// - Parameters:
        ///   - address: The starting address of the memory range.
        ///   - length: The number of bytes to lock.
        /// - Throws: `Error.lock` on failure.
        public static func lock(address: UnsafeRawPointer, length: Kernel.File.Size) throws(Error) {
            guard VirtualLock(UnsafeMutableRawPointer(mutating: address), SIZE_T(Int(length))) else {
                throw .lock(.captureLastError())
            }
        }

        /// Unlocks pages in memory, allowing them to be swapped.
        ///
        /// - Parameters:
        ///   - address: The starting address of the memory range.
        ///   - length: The number of bytes to unlock.
        /// - Throws: `Error.unlock` on failure.
        public static func unlock(address: UnsafeRawPointer, length: Kernel.File.Size) throws(Error) {
            guard VirtualUnlock(UnsafeMutableRawPointer(mutating: address), SIZE_T(Int(length))) else {
                throw .unlock(.captureLastError())
            }
        }
    }

#endif
