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
    /// Socket pair operations.
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
        /// Creates a connected pair of Unix domain sockets.
        ///
        /// Creates two connected sockets that can be used for bidirectional
        /// communication. Both sockets are stream sockets (SOCK_STREAM).
        ///
        /// - Returns: A tuple containing two connected socket descriptors.
        /// - Throws: `Error` on failure.
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
        /// - Note: Windows does not have native socketpair. This creates a
        ///   pair of connected TCP sockets using loopback.
        ///
        /// - Returns: A tuple containing two connected socket descriptors.
        /// - Throws: `Error` on failure.
        @inlinable
        public static func create() throws(Error) -> (Kernel.Socket.Descriptor, Kernel.Socket.Descriptor) {
            // Windows implementation would use a listener on loopback
            // and connect to create a socket pair. For now, throw unsupported.
            throw .platform(.unsupported)
        }
    }

#endif
