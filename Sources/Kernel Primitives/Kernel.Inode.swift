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
    /// Filesystem inode number.
    ///
    /// A type-safe wrapper for inode identifiers. An inode uniquely identifies
    /// a file within a filesystem.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let stats1 = try Kernel.File.Stats.get(path1)
    /// let stats2 = try Kernel.File.Stats.get(path2)
    /// if stats1.inode == stats2.inode && stats1.device == stats2.device {
    ///     // Both paths refer to the same file (hard links or same path)
    /// }
    /// ```
    public struct Inode: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt64

        /// Creates an inode from a raw value.
        @inlinable
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        /// Creates an inode from a UInt64 value.
        @inlinable
        public init(_ value: UInt64) {
            self.rawValue = value
        }
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Kernel.Inode: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: UInt64) {
        self.rawValue = value
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Inode: CustomStringConvertible {
    public var description: String {
        "\(rawValue)"
    }
}
