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
    /// User-related types.
    public enum User {}
}

// MARK: - User.ID

extension Kernel.User {
    /// POSIX user ID.
    ///
    /// A type-safe wrapper for user identifiers used in file ownership
    /// and permission checks.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let stats = try Kernel.File.Stats.get(path)
    /// if stats.uid == .root {
    ///     // File is owned by root
    /// }
    /// ```
    public typealias ID = Tagged<Kernel.User, UInt32>
}

// MARK: - User.ID Constants

extension Tagged where Tag == Kernel.User, RawValue == UInt32 {
    /// The root user (uid 0).
    public static var root: Self { Self(0) }
}
