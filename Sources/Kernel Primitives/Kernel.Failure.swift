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

extension Kernel {
    /// Unified error type for all kernel syscalls.
    ///
    /// Aggregates domain-specific leaf errors into a single type for use in
    /// generic syscall contexts. Each case wraps the authoritative domain error.
    ///
    /// ## Design Principles
    /// - **Semantic, not platform-specific**: Cases represent user-actionable conditions.
    /// - **Typed throws**: No `rethrows`, no `any Error`.
    /// - **Domain leaf errors**: Each case wraps the domain's own error type.
    /// - **EOF is NOT an error**: `read`/`pread` return 0 on EOF.
    public enum Failure: Swift.Error, Sendable, Equatable {
        /// Path resolution errors.
        case path(Kernel.Path.Resolution.Error)

        /// File descriptor/handle errors.
        case handle(Kernel.Descriptor.Validity.Error)

        /// I/O operation errors.
        /// Note: EOF is NOT an error. read/pread return 0 on EOF.
        case io(Kernel.IO.Error)

        /// File locking errors.
        case lock(Kernel.Lock.Error)

        /// Memory-related errors.
        case memory(Kernel.Memory.Error)

        /// Permission errors.
        case permission(Kernel.Permission.Error)

        /// Storage space errors.
        case space(Kernel.Storage.Error)

        /// Non-blocking operation errors.
        case blocking(Kernel.IO.Blocking.Error)

        /// Unmapped platform-specific errors.
        case platform(Kernel.Error.Unmapped.Error)
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Failure: CustomStringConvertible {
    public var description: String {
        switch self {
        case .path(let error):
            return "path: \(error)"
        case .handle(let error):
            return "handle: \(error)"
        case .io(let error):
            return "io: \(error)"
        case .lock(let error):
            return "lock: \(error)"
        case .memory(let error):
            return "memory: \(error)"
        case .permission(let error):
            return "permission: \(error)"
        case .space(let error):
            return "space: \(error)"
        case .blocking(let error):
            return "blocking: \(error)"
        case .platform(let error):
            return "\(error)"
        }
    }
}

#if os(Windows)
    public import WinSDK
#endif

extension Kernel.Failure {
    public init?(
        _ code: Kernel.Error.Code
    ) {
        // Try each domain in priority order
        if let e = Kernel.Path.Resolution.Error(code: code) {
            self = .path(e)
            return
        }
        if let e = Kernel.Permission.Error(code: code) {
            self = .permission(e)
            return
        }
        if let e = Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        if let e = Kernel.IO.Blocking.Error(code: code) {
            self = .blocking(e)
            return
        }
        if let e = Kernel.Storage.Error(code: code) {
            self = .space(e)
            return
        }
        if let e = Kernel.Memory.Error(code: code) {
            self = .memory(e)
            return
        }
        if let e = Kernel.IO.Error(code: code) {
            self = .io(e)
            return
        }
        if let e = Kernel.Lock.Error(code: code) {
            self = .lock(e)
            return
        }
        return nil
    }
}

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Failure {
    /// Returns the platform error message for a given error code.
    ///
    /// On POSIX, calls `strerror` for `.posix` codes.
    /// On Windows, calls `FormatMessageW` for `.win32` codes.
    ///
    /// - Parameter code: The unified error code.
    /// - Returns: A human-readable error message, or `nil` if not available.
    public static func message(for code: Kernel.Error.Code) -> String? {
        switch code {
        case .posix(let rawValue):
            #if !os(Windows)
                return String(cString: strerror(rawValue))
            #else
                return nil
            #endif

        case .win32(let rawValue):
            #if os(Windows)
                let flags: DWORD =
                    DWORD(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS)

                var buffer: LPWSTR? = nil

                // MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT) = (1 << 10) | 0 = 0x0400
                let langId: DWORD = 0x0400

                let length: DWORD = withUnsafeMutablePointer(to: &buffer) { bufferPtr in
                    bufferPtr.withMemoryRebound(to: WCHAR.self, capacity: 1) { widePtr in
                        FormatMessageW(
                            flags,
                            nil,
                            rawValue,
                            langId,
                            widePtr,
                            0,
                            nil
                        )
                    }
                }

                guard length > 0, let buffer else { return nil }
                defer { _ = LocalFree(buffer) }

                let u16 = UnsafeBufferPointer(start: buffer, count: Int(length))
                var message = String(decoding: u16, as: UTF16.self)

                // Trim trailing whitespace/newlines without Foundation
                while let last = message.unicodeScalars.last,
                    last == "\r" || last == "\n" || last == " " || last == "\t"
                {
                    message.unicodeScalars.removeLast()
                }
                return message
            #else
                return nil
            #endif
        }
    }
}
