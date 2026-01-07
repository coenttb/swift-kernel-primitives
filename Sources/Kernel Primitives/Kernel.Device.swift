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

        // MARK: - Major/Minor Extraction (POSIX)

        #if !os(Windows)
            /// The major device number (identifies device type/driver).
            ///
            /// This uses the standard Linux encoding for dev_t.
            @inlinable
            public var major: UInt32 {
                UInt32((rawValue >> 8) & 0xFFF)
            }

            /// The minor device number (identifies specific device instance).
            ///
            /// This uses the standard Linux encoding for dev_t.
            @inlinable
            public var minor: UInt32 {
                UInt32((rawValue & 0xFF) | ((rawValue >> 12) & 0xFFF00))
            }

            /// Creates a device ID from major and minor numbers.
            @inlinable
            public init(major: UInt32, minor: UInt32) {
                let majorPart = UInt64(major & 0xFFF) << 8
                let minorLow = UInt64(minor & 0xFF)
                let minorHigh = UInt64((minor & 0xFFF00)) << 12
                self.rawValue = majorPart | minorLow | minorHigh
            }
        #endif
    }
}

// MARK: - Typed Major/Minor (POSIX)

#if !os(Windows)
    extension Kernel.Device {
        /// Type-safe wrapper for a major device number.
        ///
        /// This is a semantic wrapper only, not a validated range.
        /// Construction does not enforce kernel limits.
        public struct Major: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }

        /// Type-safe wrapper for a minor device number.
        ///
        /// This is a semantic wrapper only, not a validated range.
        /// Construction does not enforce kernel limits.
        public struct Minor: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }

        /// Typed major device number.
        public var typedMajor: Major {
            Major(rawValue: major)
        }

        /// Typed minor device number.
        public var typedMinor: Minor {
            Minor(rawValue: minor)
        }

        /// Creates a device ID from typed major and minor numbers.
        public init(major: Major, minor: Minor) {
            self.init(major: major.rawValue, minor: minor.rawValue)
        }
    }
#endif

// MARK: - ExpressibleByIntegerLiteral

extension Kernel.Device: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: UInt64) {
        self.rawValue = value
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Device: CustomStringConvertible {
    public var description: String {
        #if os(Windows)
            return "\(rawValue)"
        #else
            return "\(major):\(minor)"
        #endif
    }
}
