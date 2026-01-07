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

extension Kernel.File {
    /// POSIX file permissions.
    ///
    /// A type-safe wrapper for POSIX file permission bits (mode_t).
    /// Provides common presets and composition via the `|` operator.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Common presets
    /// let fd = try Kernel.File.Open.open(path: path, permissions: .standard)
    /// let exe = try Kernel.File.Open.open(path: path, permissions: .executable)
    ///
    /// // Combine permissions
    /// let custom = Permissions.ownerReadWrite | .groupRead | .otherRead
    /// ```
    public struct Permissions: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt16

        @inlinable
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }

        // MARK: - Owner Permissions

        /// Owner read permission (0o400).
        public static let ownerRead = Permissions(rawValue: 0o400)

        /// Owner write permission (0o200).
        public static let ownerWrite = Permissions(rawValue: 0o200)

        /// Owner execute permission (0o100).
        public static let ownerExecute = Permissions(rawValue: 0o100)

        /// Owner read and write permissions (0o600).
        public static let ownerReadWrite = Permissions(rawValue: 0o600)

        /// Owner read, write, and execute permissions (0o700).
        public static let ownerAll = Permissions(rawValue: 0o700)

        // MARK: - Group Permissions

        /// Group read permission (0o040).
        public static let groupRead = Permissions(rawValue: 0o040)

        /// Group write permission (0o020).
        public static let groupWrite = Permissions(rawValue: 0o020)

        /// Group execute permission (0o010).
        public static let groupExecute = Permissions(rawValue: 0o010)

        /// Group read and write permissions (0o060).
        public static let groupReadWrite = Permissions(rawValue: 0o060)

        /// Group read, write, and execute permissions (0o070).
        public static let groupAll = Permissions(rawValue: 0o070)

        // MARK: - Other Permissions

        /// Other read permission (0o004).
        public static let otherRead = Permissions(rawValue: 0o004)

        /// Other write permission (0o002).
        public static let otherWrite = Permissions(rawValue: 0o002)

        /// Other execute permission (0o001).
        public static let otherExecute = Permissions(rawValue: 0o001)

        /// Other read and write permissions (0o006).
        public static let otherReadWrite = Permissions(rawValue: 0o006)

        /// Other read, write, and execute permissions (0o007).
        public static let otherAll = Permissions(rawValue: 0o007)

        // MARK: - Common Presets

        /// No permissions (0o000).
        public static let none = Permissions(rawValue: 0o000)

        /// Standard file permissions: rw-r--r-- (0o644).
        ///
        /// Owner can read and write; group and others can read.
        public static let standard = Permissions(rawValue: 0o644)

        /// Executable file permissions: rwxr-xr-x (0o755).
        ///
        /// Owner can read, write, and execute; group and others can read and execute.
        public static let executable = Permissions(rawValue: 0o755)

        /// Private file permissions: rw------- (0o600).
        ///
        /// Only the owner can read and write.
        public static let privateFile = Permissions(rawValue: 0o600)

        /// Private executable permissions: rwx------ (0o700).
        ///
        /// Only the owner can read, write, and execute.
        public static let privateExecutable = Permissions(rawValue: 0o700)

        /// Private directory permissions: rwx------ (0o700).
        ///
        /// Only the owner can access the directory.
        public static let privateDirectory = Permissions(rawValue: 0o700)

        /// Standard directory permissions: rwxr-xr-x (0o755).
        ///
        /// Owner has full access; group and others can read and traverse.
        public static let standardDirectory = Permissions(rawValue: 0o755)

        // MARK: - Operators

        /// Combines two permission sets.
        @inlinable
        public static func | (lhs: Permissions, rhs: Permissions) -> Permissions {
            Permissions(rawValue: lhs.rawValue | rhs.rawValue)
        }

        /// Combines permission sets in place.
        @inlinable
        public static func |= (lhs: inout Permissions, rhs: Permissions) {
            lhs = lhs | rhs
        }

        /// Intersects two permission sets.
        @inlinable
        public static func & (lhs: Permissions, rhs: Permissions) -> Permissions {
            Permissions(rawValue: lhs.rawValue & rhs.rawValue)
        }

        /// Inverts permissions (bitwise NOT).
        @inlinable
        public static prefix func ~ (permissions: Permissions) -> Permissions {
            Permissions(rawValue: ~permissions.rawValue)
        }
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Kernel.File.Permissions: ExpressibleByIntegerLiteral {
    /// Creates permissions from an octal integer literal.
    ///
    /// ```swift
    /// let perms: Kernel.File.Permissions = 0o755
    /// ```
    @inlinable
    public init(integerLiteral value: UInt16) {
        self.rawValue = value
    }
}

// MARK: - CustomStringConvertible

extension Kernel.File.Permissions: CustomStringConvertible {
    public var description: String {
        let owner = "\(rawValue & 0o400 != 0 ? "r" : "-")\(rawValue & 0o200 != 0 ? "w" : "-")\(rawValue & 0o100 != 0 ? "x" : "-")"
        let group = "\(rawValue & 0o040 != 0 ? "r" : "-")\(rawValue & 0o020 != 0 ? "w" : "-")\(rawValue & 0o010 != 0 ? "x" : "-")"
        let other = "\(rawValue & 0o004 != 0 ? "r" : "-")\(rawValue & 0o002 != 0 ? "w" : "-")\(rawValue & 0o001 != 0 ? "x" : "-")"
        return "\(owner)\(group)\(other)"
    }
}
