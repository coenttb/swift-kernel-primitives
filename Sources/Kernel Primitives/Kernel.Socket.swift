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

// MARK: - Socket Types

extension Kernel {
    /// Socket operations and types.
    ///
    /// Provides low-level socket syscall wrappers. For higher-level networking,
    /// see swift-networking which builds on these primitives.
    ///
    /// ## See Also
    /// - ``Kernel/Socket/Descriptor``
    /// - ``Kernel/Socket/Pair``
    public enum Socket: Sendable {

    }
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

    extension Kernel.Socket {
        /// Gets and clears the pending socket error (SO_ERROR).
        ///
        /// Retrieves and atomically clears the pending error on a socket.
        /// Commonly used after non-blocking connect to check connection status,
        /// or after select/poll indicates an error condition.
        ///
        /// ## Threading
        /// This call may briefly block while retrieving the socket option.
        /// The error is cleared atomically—concurrent calls may see different results.
        ///
        /// ## State Effects
        /// The pending error is **cleared** by this call. Subsequent calls return
        /// `.posix(0)` until a new error occurs.
        ///
        /// ## Errors
        /// - ``Error/handle(_:)``: Invalid socket descriptor
        /// - ``Error/notSocket``: Descriptor is not a socket
        ///
        /// - Parameter descriptor: The socket descriptor.
        /// - Returns: The error code (`.posix(0)` if no pending error).
        /// - Throws: ``Kernel/Socket/Error`` if getsockopt fails.
        @inlinable
        public static func getError(_ descriptor: Descriptor) throws(Error) -> Kernel.Error.Code {
            var err: Int32 = 0
            var len = socklen_t(MemoryLayout<Int32>.size)

            let rc = getsockopt(
                descriptor.rawValue,
                SOL_SOCKET,
                SO_ERROR,
                &err,
                &len
            )

            try Kernel.Syscall.require(rc, .equals(0), orThrow: Error.current())

            return .posix(err)
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.Socket {
        /// Gets and clears the pending socket error (SO_ERROR).
        ///
        /// Retrieves and atomically clears the pending error on a socket.
        /// Commonly used after non-blocking connect to check connection status,
        /// or after select indicates an error condition.
        ///
        /// ## Threading
        /// This call may briefly block while retrieving the socket option.
        /// The error is cleared atomically—concurrent calls may see different results.
        ///
        /// ## State Effects
        /// The pending error is **cleared** by this call. Subsequent calls return
        /// `.win32(0)` until a new error occurs.
        ///
        /// ## Errors
        /// - ``Error/handle(_:)``: Invalid socket descriptor
        /// - ``Error/notSocket``: Descriptor is not a socket
        ///
        /// - Parameter descriptor: The socket descriptor.
        /// - Returns: The error code (`.win32(0)` if no pending error).
        /// - Throws: ``Kernel/Socket/Error`` if getsockopt fails.
        @inlinable
        public static func getError(_ descriptor: Descriptor) throws(Error) -> Kernel.Error.Code {
            var err: Int32 = 0
            var len: Int32 = Int32(MemoryLayout<Int32>.size)

            let rc = getsockopt(
                SOCKET(descriptor.rawValue),
                SOL_SOCKET,
                SO_ERROR,
                UnsafeMutableRawPointer(&err).assumingMemoryBound(to: CChar.self),
                &len
            )

            try Kernel.Syscall.require(rc, .equals(0), orThrow: Error.current())

            return .win32(UInt32(bitPattern: err))
        }
    }

#endif
