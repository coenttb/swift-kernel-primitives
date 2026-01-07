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
    /// Link-related types.
    public enum Link {}
}

// MARK: - Link.Count

extension Kernel.Link {
    /// Hard link count for a file.
    ///
    /// A type-safe wrapper for the number of hard links to a file.
    /// Regular files start with a link count of 1. Directories typically
    /// have 2 + (number of subdirectories) links.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let stats = try Kernel.File.Stats.get(path)
    /// if stats.linkCount > .one {
    ///     // File has multiple hard links
    /// }
    /// ```
    public typealias Count = Tagged<Kernel.Link, UInt32>
}

// MARK: - Link.Count Constants

extension Tagged where Tag == Kernel.Link, RawValue == UInt32 {
    /// A single link (typical for newly created files).
    public static var one: Self { Self(1) }

    /// Zero links (file is being deleted).
    public static var zero: Self { Self(0) }
}
