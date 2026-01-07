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

extension Kernel.Socket.Pair {
    /// Errors that can occur during socket pair operations.
    public enum Error: Swift.Error, Sendable {
        /// A platform-specific error.
        case platform(Platform)

        /// Platform-specific error details.
        public enum Platform: Sendable, Equatable {
            /// The operation is not supported on this platform.
            case unsupported

            /// A POSIX errno value.
            case posix(Int32)
        }
    }
}

// MARK: - Equatable

extension Kernel.Socket.Pair.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.platform(let l), .platform(let r)): return l == r
        }
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Socket.Pair.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .platform(let p):
            switch p {
            case .unsupported: return "socketpair not supported on this platform"
            case .posix(let e): return "socketpair failed: errno \(e)"
            }
        }
    }
}

// MARK: - POSIX Initialization

#if !os(Windows)

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Kernel.Socket.Pair.Error {
        @usableFromInline
        internal static func current() -> Self {
            .platform(.posix(errno))
        }
    }

#endif

// MARK: - Windows Initialization

#if os(Windows)
    public import WinSDK

    extension Kernel.Socket.Pair.Error {
        @usableFromInline
        internal static func current() -> Self {
            .platform(.posix(Int32(WSAGetLastError())))
        }
    }

#endif
