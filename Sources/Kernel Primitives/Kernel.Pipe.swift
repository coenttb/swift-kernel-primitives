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

extension Kernel {
    /// Anonymous pipe operations for inter-process/inter-thread communication.
    ///
    /// Creates unidirectional byte streams for communication. Data written to the
    /// write end can be read from the read end. Pipes are commonly used for:
    /// - Parent-child process communication
    /// - Inter-thread signaling
    /// - Implementing producer-consumer patterns
    ///
    /// ## Descriptor Lifecycle
    /// Both descriptors must be closed explicitly via ``Kernel/Close/close(_:)``.
    /// Close the write end to signal EOF to readers. Close the read end to cause
    /// writes to fail with EPIPE/SIGPIPE.
    public enum Pipe: Sendable {}
}

// MARK: - POSIX Implementation

#if canImport(Darwin)
    public import Darwin
#elseif canImport(Glibc)
    public import Glibc
#elseif canImport(Musl)
    public import Musl
#endif

#if canImport(Darwin) || canImport(Glibc) || canImport(Musl)

    extension Kernel.Pipe {
        /// Creates an anonymous pipe returning connected read and write descriptors.
        ///
        /// ## Threading
        /// The pipe syscall is atomic and does not block. The returned descriptors
        /// are created in blocking mode by default.
        ///
        /// ## Blocking Behavior
        /// - **Read**: Blocks until data is available or all write ends are closed (EOF)
        /// - **Write**: Blocks if the pipe buffer is full (typically 64KB on Linux, 16KB on macOS)
        ///
        /// ## Descriptor Lifecycle
        /// Both descriptors must be closed explicitly. Close order matters:
        /// - Close write first → readers get EOF
        /// - Close read first → writers get EPIPE/SIGPIPE
        ///
        /// ## Errors
        /// - ``Error/tooManyOpen``: Process or system descriptor limit reached
        /// - ``Error/noMemory``: Insufficient kernel memory for pipe buffer
        ///
        /// - Returns: A tuple containing `(read, write)` descriptors.
        /// - Throws: ``Kernel/Pipe/Error`` on failure.
        @inlinable
        public static func create() throws(Error) -> (read: Kernel.Descriptor, write: Kernel.Descriptor) {
            var fds: [Int32] = [0, 0]
            #if canImport(Darwin)
                try Kernel.Syscall.require(Darwin.pipe(&fds), .equals(0), orThrow: Error.current())
            #elseif canImport(Glibc)
                try Kernel.Syscall.require(Glibc.pipe(&fds), .equals(0), orThrow: Error.current())
            #elseif canImport(Musl)
                try Kernel.Syscall.require(Musl.pipe(&fds), .equals(0), orThrow: Error.current())
            #endif
            return (Kernel.Descriptor(rawValue: fds[0]), Kernel.Descriptor(rawValue: fds[1]))
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.Pipe {
        /// Creates an anonymous pipe returning connected read and write handles.
        ///
        /// ## Threading
        /// The CreatePipe call is atomic and does not block. The returned handles
        /// are created in blocking (synchronous) mode by default.
        ///
        /// ## Blocking Behavior
        /// - **Read**: Blocks until data is available or the write handle is closed
        /// - **Write**: Blocks if the pipe buffer is full
        ///
        /// ## Handle Lifecycle
        /// Both handles must be closed explicitly via ``Kernel/Close/close(_:)``.
        /// Close order matters for signaling.
        ///
        /// ## Errors
        /// - ``Error/tooManyOpen``: System handle limit reached
        /// - ``Error/noMemory``: Insufficient resources
        ///
        /// - Returns: A tuple containing `(read, write)` handles.
        /// - Throws: ``Kernel/Pipe/Error`` on failure.
        @inlinable
        public static func create() throws(Error) -> (read: Kernel.Descriptor, write: Kernel.Descriptor) {
            var readHandle: HANDLE?
            var writeHandle: HANDLE?
            let result = CreatePipe(&readHandle, &writeHandle, nil, 0)
            try Kernel.Syscall.require(result, .isTrue, orThrow: Error.current())
            return (Kernel.Descriptor(rawValue: readHandle!), Kernel.Descriptor(rawValue: writeHandle!))
        }
    }

#endif
