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
    /// A memory address as a typed position in memory space.
    ///
    /// Type-safe representation using dimensional algebra. Provides:
    /// - Alignment checking via `Binary.Alignment`
    /// - Affine arithmetic: `Address - Address = Displacement`
    /// - Type safety: cannot confuse with file offsets
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let addr = Kernel.Memory.Address(pointer)
    /// let aligned = alignment.isAligned(addr)
    /// ```
    public typealias Address = Binary.Position<UInt, Space>

    /// Displacement between memory addresses.
    public typealias Displacement = Binary.Offset<Int, Space>
}

// MARK: - Pointer Conversions

extension Kernel.Memory.Address {
    /// Creates an address from an immutable raw pointer.
    @inlinable
    public init(_ pointer: UnsafeRawPointer) {
        self.init(UInt(bitPattern: pointer))
    }

    /// Creates an address from a mutable raw pointer.
    @inlinable
    public init(_ pointer: UnsafeMutableRawPointer) {
        self.init(UInt(bitPattern: pointer))
    }

    /// The immutable raw pointer for syscall interop.
    ///
    /// Returns `nil` for the zero address.
    @inlinable
    public var pointer: UnsafeRawPointer? {
        UnsafeRawPointer(bitPattern: rawValue)
    }

    /// The mutable raw pointer for syscall interop.
    ///
    /// Returns `nil` for the zero address.
    @inlinable
    public var mutablePointer: UnsafeMutableRawPointer? {
        UnsafeMutableRawPointer(bitPattern: rawValue)
    }
}

// MARK: - Constants

extension Kernel.Memory.Address {
    /// The null address (zero).
    public static let null: Self = 0
}

// MARK: - Typed Pointer Arithmetic

extension UnsafeMutableRawPointer {
    /// Returns a pointer offset by the given file size.
    ///
    /// - Parameter size: The byte offset as a typed file size.
    /// - Returns: A pointer advanced by the size's byte count.
    @inlinable
    public func advanced(by size: Kernel.File.Size) -> UnsafeMutableRawPointer {
        advanced(by: Int(size))
    }
}

extension UnsafeRawPointer {
    /// Returns a pointer offset by the given file size.
    ///
    /// - Parameter size: The byte offset as a typed file size.
    /// - Returns: A pointer advanced by the size's byte count.
    @inlinable
    public func advanced(by size: Kernel.File.Size) -> UnsafeRawPointer {
        advanced(by: Int(size))
    }
}
