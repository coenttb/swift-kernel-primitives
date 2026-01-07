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
    /// Socket operations.
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
        /// Gets the pending socket error (SO_ERROR).
        ///
        /// This retrieves and clears the pending error on a socket.
        /// Commonly used after a non-blocking connect to check if the
        /// connection succeeded.
        ///
        /// - Parameter descriptor: The socket descriptor.
        /// - Returns: The error code (`.posix(0)` if no error).
        /// - Throws: `Kernel.Socket.Error` if getsockopt fails.
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
        /// Gets the pending socket error (SO_ERROR).
        ///
        /// This retrieves and clears the pending error on a socket.
        /// Commonly used after a non-blocking connect to check if the
        /// connection succeeded.
        ///
        /// - Parameter descriptor: The socket descriptor.
        /// - Returns: The error code (`.win32(0)` if no error).
        /// - Throws: `Kernel.Socket.Error` if getsockopt fails.
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
