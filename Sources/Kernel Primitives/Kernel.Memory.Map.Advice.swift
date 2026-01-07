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

extension Kernel.Memory.Map {
    /// Memory access advice for madvise.
    public struct Advice: Sendable, Equatable, Hashable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
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

    extension Kernel.Memory.Map.Advice {
        /// Normal access pattern.
        public static let normal = Self(rawValue: MADV_NORMAL)

        /// Sequential access expected.
        public static let sequential = Self(rawValue: MADV_SEQUENTIAL)

        /// Random access expected.
        public static let random = Self(rawValue: MADV_RANDOM)

        /// Will need this data soon.
        public static let willNeed = Self(rawValue: MADV_WILLNEED)

        /// Will not need this data soon.
        public static let dontNeed = Self(rawValue: MADV_DONTNEED)
    }

#endif

// MARK: - Windows Constants

#if os(Windows)

    extension Kernel.Memory.Map.Advice {
        public static let normal = Self(rawValue: 0)
        public static let sequential = Self(rawValue: 1)
        public static let random = Self(rawValue: 2)
        public static let willNeed = Self(rawValue: 3)
        public static let dontNeed = Self(rawValue: 4)
    }

#endif
