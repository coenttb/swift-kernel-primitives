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

extension Kernel.Memory.Map.Sync {
    /// Flags for msync operation.
    public struct Flags: Sendable, Equatable, Hashable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Combines multiple flags.
        @inlinable
        public static func | (lhs: Kernel.Memory.Map.Sync.Flags, rhs: Kernel.Memory.Map.Sync.Flags) -> Kernel.Memory.Map.Sync.Flags {
            Kernel.Memory.Map.Sync.Flags(rawValue: lhs.rawValue | rhs.rawValue)
        }
    }
}

// MARK: - POSIX Constants

#if !os(Windows)

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        public import Glibc
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Memory.Map.Sync.Flags {
        /// Perform synchronous writes.
        public static let sync = Self(rawValue: MS_SYNC)

        /// Schedule writes but return immediately.
        public static let async = Self(rawValue: MS_ASYNC)

        /// Invalidate cached data.
        public static let invalidate = Self(rawValue: MS_INVALIDATE)
    }

#endif

// MARK: - Windows Constants

#if os(Windows)

    extension Kernel.Memory.Map.Sync.Flags {
        public static let sync = Self(rawValue: 1)
        public static let async = Self(rawValue: 2)
        public static let invalidate = Self(rawValue: 4)
    }

#endif
