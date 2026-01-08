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
    /// Device ID.
    ///
    /// A type-safe wrapper for device identifiers. A device ID identifies
    /// the filesystem or device containing a file.
    ///
    /// On POSIX systems, this encodes major and minor device numbers.
    /// On Windows, this is synthesized from the volume serial number.
    ///
    /// For POSIX major/minor extraction, see `POSIX.Kernel.Device` in swift-posix.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let stats1 = try Kernel.File.Stats.get(path1)
    /// let stats2 = try Kernel.File.Stats.get(path2)
    /// if stats1.device == stats2.device {
    ///     // Both files are on the same filesystem
    /// }
    /// ```
    public struct Device: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt64

        /// Creates a device ID from a raw value.
        @inlinable
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        /// Creates a device ID from a UInt64 value.
        @inlinable
        public init(_ value: UInt64) {
            self.rawValue = value
        }
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Kernel.Device: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: UInt64) {
        self.rawValue = value
    }
}
