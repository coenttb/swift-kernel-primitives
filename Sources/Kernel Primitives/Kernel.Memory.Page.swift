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
    /// Page-related types.
    public enum Page {}
}

// MARK: - Page.Size

extension Kernel.Memory.Page {
    /// Memory page size in bytes.
    ///
    /// A type-safe wrapper for the system's memory page size.
    /// This is the fundamental unit of memory management.
    ///
    /// ## Platform Values
    ///
    /// - x86-64: Typically 4096 bytes
    /// - Apple Silicon: 16384 bytes
    /// - Windows: Typically 4096 bytes
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let pageSize = Kernel.System.page.size
    /// let alignedSize = (requestedSize + Int(pageSize) - 1) & ~(Int(pageSize) - 1)
    /// ```
    public typealias Size = Tagged<Kernel.Memory.Page, Int>
}

// MARK: - Conversions

extension Int {
    /// Creates an Int from a page size.
    @inlinable
    public init(_ size: Kernel.Memory.Page.Size) {
        self = size.rawValue
    }
}

extension Binary.Alignment {
    /// Creates an alignment from a page size.
    ///
    /// Page sizes are always powers of two and valid alignment values.
    @inlinable
    public init(_ pageSize: Kernel.Memory.Page.Size) {
        // Page sizes from the kernel are always powers of 2
        // swiftlint:disable:next force_try
        self = try! Binary.Alignment(pageSize.rawValue)
    }
}

extension Kernel.Memory.Page.Size {
    /// Returns this page size as a `Binary.Alignment`.
    ///
    /// Page sizes are always valid alignment values.
    @inlinable
    public var alignment: Binary.Alignment {
        Binary.Alignment(self)
    }
}
