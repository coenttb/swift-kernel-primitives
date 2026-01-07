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

public import Binary

extension Kernel.File.System {
    /// Filesystem block types.
    public enum Block {}
}

// MARK: - Block.Size

extension Kernel.File.System.Block {
    /// Filesystem block size.
    ///
    /// A type-safe size value using the Dimension pattern.
    /// Follows the same pattern as `Kernel.File.Size`.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let stats = try Kernel.File.System.Stats.get(path)
    /// let totalBytes = stats.blocks.rawValue * stats.blockSize.rawValue
    /// ```
    public typealias Size = Magnitude<Kernel.File.System.Block>.Value<UInt64>
}

// MARK: - Block.Size Constants

extension Kernel.File.System.Block.Size {
    /// 512-byte sector (traditional disk sector).
    public static let sector512: Self = 512

    /// 4096-byte page (common filesystem block size).
    public static let page4096: Self = 4096
}

// MARK: - Block.Count

extension Kernel.File.System.Block {
    /// Block count for filesystem statistics.
    ///
    /// A type-safe wrapper for filesystem block counts (total, free, available).
    /// Multiply by the block size to get the size in bytes.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let stats = try Kernel.File.System.Stats.get(path)
    /// let freeBytes = stats.freeBlocks.rawValue * stats.blockSize.rawValue
    /// ```
    public typealias Count = Tagged<Kernel.File.System.Block, UInt64>
}

// MARK: - Block.Count Constants & Arithmetic

extension Tagged where Tag == Kernel.File.System.Block, RawValue == UInt64 {
    /// Zero blocks.
    public static var zero: Self { Self(0) }

    /// Adds two block counts.
    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.rawValue + rhs.rawValue)
    }

    /// Subtracts two block counts.
    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(lhs.rawValue - rhs.rawValue)
    }
}
