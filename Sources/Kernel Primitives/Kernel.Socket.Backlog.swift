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
    /// Listen backlog size.
    ///
    /// Specifies the maximum length of the queue of pending connections
    /// for the `listen` syscall.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// try socket.listen(backlog: .default)
    /// try socket.listen(backlog: Backlog(1024))
    /// ```
    ///
    /// ## Platform Notes
    ///
    /// - On Linux, the actual maximum is governed by `/proc/sys/net/core/somaxconn`.
    /// - On macOS/BSD, the system may silently cap this value.
    /// - Some systems treat `SOMAXCONN` specially to mean "use system maximum".
    public struct Backlog: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        /// Creates a backlog from a raw value.
        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Creates a backlog from an Int32 value.
        @inlinable
        public init(_ value: Int32) {
            self.rawValue = value
        }

        // MARK: - Common Values

        /// Default backlog (128).
        ///
        /// A reasonable default for most applications.
        public static let `default` = Backlog(128)

        /// Small backlog (16).
        ///
        /// Suitable for low-traffic services.
        public static let small = Backlog(16)

        /// Large backlog (4096).
        ///
        /// For high-traffic servers that can handle many pending connections.
        public static let large = Backlog(4096)

        #if !os(Windows)
            /// System maximum backlog.
            ///
            /// Uses `SOMAXCONN` which typically maps to the system's maximum
            /// allowed backlog value.
            public static var max: Backlog {
                #if canImport(Darwin)
                    return Backlog(Darwin.SOMAXCONN)
                #elseif canImport(Glibc)
                    return Backlog(Glibc.SOMAXCONN)
                #elseif canImport(Musl)
                    return Backlog(Musl.SOMAXCONN)
                #endif
            }
        #endif
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Kernel.Socket.Backlog: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Int32) {
        self.rawValue = value
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Socket.Backlog: CustomStringConvertible {
    public var description: String {
        "\(rawValue)"
    }
}

// MARK: - Platform Imports

#if !os(Windows)
    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        public import Glibc
    #elseif canImport(Musl)
        public import Musl
    #endif
#endif
