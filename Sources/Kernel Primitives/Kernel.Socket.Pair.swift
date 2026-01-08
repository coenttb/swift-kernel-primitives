// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Kernel.Socket {
    /// Socket pair operations for bidirectional inter-process communication.
    ///
    /// Creates a pair of connected Unix domain sockets. Unlike pipes, socket pairs
    /// are bidirectional—both ends can read and write. Commonly used for:
    /// - Full-duplex IPC between related processes
    /// - Event notification with bidirectional acknowledgment
    /// - Testing network code without actual network I/O
    ///
    /// ## Descriptor Lifecycle
    /// Both descriptors must be closed explicitly via ``Kernel/Close/close(_:)``.
    /// Closing one end causes reads on the other to return EOF and writes to fail.
    public enum Pair: Sendable {}
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

    extension Kernel.Socket.Pair {
        /// Creates a connected pair of Unix domain stream sockets.
        ///
        /// Both sockets are `AF_UNIX` / `SOCK_STREAM` and can be used for
        /// bidirectional communication. Data written to one socket can be read
        /// from the other, and vice versa.
        ///
        /// ## Threading
        /// The socketpair syscall is atomic and does not block. The returned
        /// descriptors are created in blocking mode by default.
        ///
        /// ## Blocking Behavior
        /// - **Read**: Blocks until data is available or the peer is closed (EOF)
        /// - **Write**: Blocks if the socket buffer is full
        ///
        /// ## Descriptor Lifecycle
        /// Both descriptors must be closed explicitly. They are independent—closing
        /// one does not automatically close the other.
        ///
        /// ## Errors
        /// - ``Error/tooManyOpen``: Process or system descriptor limit reached
        /// - ``Error/noMemory``: Insufficient kernel memory
        ///
        /// - Returns: A tuple containing two connected socket descriptors.
        /// - Throws: ``Kernel/Socket/Pair/Error`` on failure.
        @inlinable
        public static func create() throws(Error) -> (Kernel.Socket.Descriptor, Kernel.Socket.Descriptor) {
            var fds: [Int32] = [0, 0]
            #if canImport(Darwin)
                let result = Darwin.socketpair(AF_UNIX, SOCK_STREAM, 0, &fds)
            #elseif canImport(Glibc)
                let result = Glibc.socketpair(AF_UNIX, Int32(SOCK_STREAM.rawValue), 0, &fds)
            #elseif canImport(Musl)
                let result = Musl.socketpair(AF_UNIX, SOCK_STREAM, 0, &fds)
            #endif
            guard result == 0 else {
                throw Error.current()
            }
            return (Kernel.Socket.Descriptor(rawValue: fds[0]), Kernel.Socket.Descriptor(rawValue: fds[1]))
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.Socket.Pair {
        /// Creates a connected pair of sockets.
        ///
        /// ## Platform Limitation
        /// Windows does not have a native `socketpair()` syscall. A full implementation
        /// would create a TCP loopback listener, connect to it, accept, then close
        /// the listener. This is not yet implemented.
        ///
        /// ## Errors
        /// - ``Error/platform(_:)``: Always throws `.unsupported` on Windows
        ///
        /// - Returns: Never returns successfully on Windows.
        /// - Throws: ``Kernel/Socket/Pair/Error`` with `.platform(.unsupported)`.
        @inlinable
        public static func create() throws(Error) -> (Kernel.Socket.Descriptor, Kernel.Socket.Descriptor) {
            throw .platform(.unsupported)
        }
    }

#endif
