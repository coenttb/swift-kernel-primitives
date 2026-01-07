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

extension Kernel.File {
    /// File offset for positional I/O operations.
    ///
    /// A type-safe coordinate for file positions. Provides dimensional arithmetic:
    /// - `Offset - Offset = Delta` (difference between positions)
    /// - `Offset + Delta = Offset` (translate position)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let start: Kernel.File.Offset = 1000
    /// let end: Kernel.File.Offset = 5000
    /// let distance = end - start  // Delta (4000 bytes)
    /// let next = start + distance // Offset (5000)
    /// ```
    public typealias Offset = Coordinate.X<Space>.Value<Int64>

    /// Signed displacement between file offsets.
    ///
    /// The result of subtracting two offsets. Can be positive or negative.
    public typealias Delta = Displacement.X<Space>.Value<Int64>
}

// MARK: - Offset Constants

extension Kernel.File.Offset {
    /// Zero offset (beginning of file).
    public static let zero: Self = 0

    /// Maximum offset (end of file marker for lock ranges).
    public static let max = Self(Int64.max)
}

// MARK: - Convenience Initializers

extension Kernel.File.Offset {
    /// Creates a file offset from an Int value.
    @inlinable
    public init(_ value: Int) {
        self.init(Int64(value))
    }
}
