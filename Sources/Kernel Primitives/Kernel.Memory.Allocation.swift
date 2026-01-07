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

extension Kernel.Memory {
    /// Allocation-related types.
    public enum Allocation {}
}

// MARK: - Allocation.Granularity

extension Kernel.Memory.Allocation {
    /// Allocation alignment granularity in bytes.
    ///
    /// A type-safe wrapper for the system's allocation granularity.
    /// Memory mapping offsets must be aligned to this value.
    ///
    /// ## Platform Values
    ///
    /// - POSIX: Equals page size (typically 4096 or 16384 bytes)
    /// - Windows: Typically 65536 bytes (64KB)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let granularity = Kernel.System.allocation.granularity
    /// let alignedOffset = offset & ~(Int64(granularity) - 1)
    /// ```
    public typealias Granularity = Tagged<Kernel.Memory.Allocation, Int>
}

// MARK: - Conversions

extension Int {
    /// Creates an Int from an allocation granularity.
    @inlinable
    public init(_ granularity: Kernel.Memory.Allocation.Granularity) {
        self = granularity.rawValue
    }
}

extension Int64 {
    /// Creates an Int64 from an allocation granularity.
    @inlinable
    public init(_ granularity: Kernel.Memory.Allocation.Granularity) {
        self = Int64(granularity.rawValue)
    }
}

extension Binary.Alignment {
    /// Creates an alignment from an allocation granularity.
    ///
    /// Allocation granularities are always powers of two and valid alignment values.
    @inlinable
    public init(_ granularity: Kernel.Memory.Allocation.Granularity) {
        // Allocation granularities from the kernel are always powers of 2
        // swiftlint:disable:next force_try
        self = try! Binary.Alignment(granularity.rawValue)
    }
}

extension Kernel.Memory.Allocation.Granularity {
    /// Returns this granularity as a `Binary.Alignment`.
    ///
    /// Allocation granularities are always valid alignment values.
    @inlinable
    public var alignment: Binary.Alignment {
        Binary.Alignment(self)
    }
}
