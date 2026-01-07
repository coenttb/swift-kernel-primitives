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

#if !os(Windows)

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        public import Glibc
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Socket {
        /// Socket creation flags.
        ///
        /// Flags that can be combined with socket type when creating a socket.
        /// These affect the behavior of the created socket descriptor.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// let flags: Socket.Flags = [.nonBlock, .closeOnExec]
        /// ```
        public struct Flags: OptionSet, Sendable {
            public let rawValue: Int32

            /// Creates socket flags from a raw value.
            @inlinable
            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }

            // MARK: - Standard Flags

            /// Set the socket to non-blocking mode.
            ///
            /// Equivalent to setting `O_NONBLOCK` after socket creation.
            public static let nonBlock = Flags(rawValue: O_NONBLOCK)

            /// Set close-on-exec flag on the socket descriptor.
            ///
            /// Equivalent to setting `O_CLOEXEC` after socket creation.
            public static let closeOnExec = Flags(rawValue: O_CLOEXEC)

            // MARK: - Common Combinations

            /// No special flags.
            public static let none = Flags([])

            /// Non-blocking with close-on-exec (common for async I/O).
            public static let asyncDefault: Flags = [.nonBlock, .closeOnExec]
        }
    }

#endif
