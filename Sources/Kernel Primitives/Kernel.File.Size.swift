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
    /// File size as a non-directional magnitude.
    ///
    /// A type-safe wrapper for file sizes and byte counts. Uses the Dimension module
    /// to provide proper dimensional arithmetic with `Offset` and `Delta`:
    /// - `Offset + Size = Offset` (translate position by size)
    /// - `Size + Size = Size` (combine sizes)
    /// - `Size - Size = Size` (difference of sizes)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let size: Kernel.File.Size = 4096
    /// let offset: Kernel.File.Offset = 1000
    /// let newOffset = offset + size  // File.Offset
    ///
    /// // Create from pages
    /// let pageSize = Kernel.File.Size(pages: 4)
    /// ```
    public typealias Size = Magnitude<Space>.Value<Int64>
}

// MARK: - Size Constants

extension Kernel.File.Size {
    /// Zero bytes.
    public static let zero: Self = 0

    /// One kilobyte (1024 bytes).
    public static let kilobyte: Self = 1024

    /// One megabyte (1024 * 1024 bytes).
    public static let megabyte: Self = Self(1024 * 1024)

    /// One gigabyte (1024 * 1024 * 1024 bytes).
    public static let gigabyte: Self = Self(1024 * 1024 * 1024)

    /// One system page.
    public static var page: Self {
        Self(Int64(Int(Kernel.System.pageSize)))
    }
}

// MARK: - Convenience Initializers

extension Kernel.File.Size {
    /// Creates a file size from a number of pages.
    ///
    /// - Parameter pages: Number of pages.
    @inlinable
    public init(pages: Int) {
        self.init(Int64(pages * Int(Kernel.System.pageSize)))
    }

    /// Creates a file size from an Int value.
    @inlinable
    public init(_ value: Int) {
        self.init(Int64(value))
    }

    /// Creates a file size from a UInt64 value.
    @inlinable
    public init(_ value: UInt64) {
        self.init(Int64(bitPattern: value))
    }

    /// Creates a file size from a file delta.
    ///
    /// Use this when converting a non-negative displacement to a magnitude.
    /// For example, when computing the offset padding after alignment:
    /// ```swift
    /// let delta = requestedOffset - alignedOffset  // File.Delta
    /// let padding = File.Size(delta)               // Convert to Size
    /// ```
    ///
    /// - Parameter delta: The file delta (must be non-negative).
    /// - Precondition: `delta` must be non-negative.
    @inlinable
    public init(_ delta: Kernel.File.Delta) {
        precondition(delta.rawValue >= 0, "Delta must be non-negative to convert to Size")
        self.init(delta.rawValue)
    }
}

// MARK: - Queries

extension Kernel.File.Size {
    /// Whether this size is zero.
    @inlinable
    public var isZero: Bool {
        rawValue == 0
    }

    /// Whether this size is positive (greater than zero).
    @inlinable
    public var isPositive: Bool {
        rawValue > 0
    }
}

// MARK: - Alignment

extension Kernel.File.Size {
    /// Whether this size is aligned to the given alignment.
    ///
    /// - Parameter alignment: The alignment boundary (power of 2).
    /// - Returns: `true` if this size is a multiple of the alignment.
    public func isAligned(to alignment: Binary.Alignment) -> Bool {
        let mask: Int64 = alignment.mask()
        return rawValue & mask == 0
    }

    /// Rounds this size down to the nearest alignment boundary.
    ///
    /// - Parameter alignment: The alignment boundary (power of 2).
    /// - Returns: The largest aligned size ≤ `self`.
    public func alignedDown(to alignment: Binary.Alignment) -> Self {
        let mask: Int64 = alignment.mask()
        return Self(rawValue & ~mask)
    }

    /// Rounds this size up to the nearest alignment boundary.
    ///
    /// - Parameter alignment: The alignment boundary (power of 2).
    /// - Returns: The smallest aligned size ≥ `self`.
    public func alignedUp(to alignment: Binary.Alignment) -> Self {
        let mask: Int64 = alignment.mask()
        return Self((rawValue &+ mask) & ~mask)
    }
}

// MARK: - Int from File.Size

extension Int {
    /// Creates an Int from a file size for syscall boundaries.
    ///
    /// - Parameter size: The file size.
    @inlinable
    public init(_ size: Kernel.File.Size) {
        self = Int(size.rawValue)
    }
}

// MARK: - Offset + Size Arithmetic

/// Adds a file size to an offset.
@inlinable
public func + (lhs: Kernel.File.Offset, rhs: Kernel.File.Size) -> Kernel.File.Offset {
    Kernel.File.Offset(lhs.rawValue + rhs.rawValue)
}

/// Adds a file size to an offset in place.
@inlinable
public func += (lhs: inout Kernel.File.Offset, rhs: Kernel.File.Size) {
    lhs = lhs + rhs
}

/// Subtracts a file size from an offset.
@inlinable
public func - (lhs: Kernel.File.Offset, rhs: Kernel.File.Size) -> Kernel.File.Offset {
    Kernel.File.Offset(lhs.rawValue - rhs.rawValue)
}

/// Subtracts a file size from an offset in place.
@inlinable
public func -= (lhs: inout Kernel.File.Offset, rhs: Kernel.File.Size) {
    lhs = lhs - rhs
}
