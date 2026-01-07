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
    /// Group-related types.
    public enum Group {}
}

// MARK: - Group.ID

extension Kernel.Group {
    /// POSIX group ID.
    ///
    /// A type-safe wrapper for group identifiers used in file ownership
    /// and permission checks.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let stats = try Kernel.File.Stats.get(path)
    /// if stats.gid == .root {
    ///     // File is owned by root group
    /// }
    /// ```
    public typealias ID = Tagged<Kernel.Group, UInt32>
}

// MARK: - Group.ID Constants

extension Tagged where Tag == Kernel.Group, RawValue == UInt32 {
    /// The root group (gid 0).
    public static var root: Self { Self(0) }
}
