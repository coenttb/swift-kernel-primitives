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

extension Kernel.File.System {
    /// Filesystem type identifier.
    ///
    /// A type-safe wrapper for filesystem type/magic identifiers.
    /// On POSIX, this is the filesystem magic number from statfs.
    /// On Windows, this is the volume serial number.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let stats = try Kernel.File.System.Stats.get(path)
    /// #if os(Linux)
    /// if stats.type == .ext4 {
    ///     // ext4 filesystem
    /// }
    /// #endif
    /// ```
    public struct Kind: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt64

        /// Creates a filesystem type from a raw value.
        @inlinable
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        /// Creates a filesystem type from a UInt64 value.
        @inlinable
        public init(_ value: UInt64) {
            self.rawValue = value
        }

        // MARK: - Common Filesystem Types (Linux)

        #if os(Linux)
            /// ext4 filesystem magic number.
            public static let ext4 = Kind(rawValue: 0xEF53)

            /// Btrfs filesystem magic number.
            public static let btrfs = Kind(rawValue: 0x9123_683E)

            /// XFS filesystem magic number.
            public static let xfs = Kind(rawValue: 0x5846_5342)

            /// tmpfs filesystem magic number.
            public static let tmpfs = Kind(rawValue: 0x0102_1994)

            /// proc filesystem magic number.
            public static let proc = Kind(rawValue: 0x9FA0)

            /// sysfs filesystem magic number.
            public static let sysfs = Kind(rawValue: 0x6265_6572)

            /// NFS filesystem magic number.
            public static let nfs = Kind(rawValue: 0x6969)

            /// CIFS/SMB filesystem magic number.
            public static let cifs = Kind(rawValue: 0xFF53_4D42)
        #endif
    }
}

// MARK: - CustomStringConvertible

extension Kernel.File.System.Kind: CustomStringConvertible {
    public var description: String {
        #if os(Linux)
            switch self {
            case .ext4: return "ext4"
            case .btrfs: return "btrfs"
            case .xfs: return "xfs"
            case .tmpfs: return "tmpfs"
            case .proc: return "proc"
            case .sysfs: return "sysfs"
            case .nfs: return "nfs"
            case .cifs: return "cifs"
            default: return "0x\(String(rawValue, radix: 16))"
            }
        #else
            return "\(rawValue)"
        #endif
    }
}
