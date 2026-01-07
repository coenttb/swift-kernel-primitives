// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
    public import WinSDK
#endif

extension Kernel.Memory.Map {
    /// A mapped memory region.
    ///
    /// Represents a region of memory that has been mapped into the process
    /// address space. This type abstracts over platform differences:
    /// - On POSIX: wraps the base address and length
    /// - On Windows: also tracks the mapping handle for cleanup
    ///
    /// Regions are created by `Kernel.Memory.Map.map()` and related functions.
    /// Use `Kernel.Memory.Map.unmap(_:)` to release the region.
    public struct Region: @unchecked Sendable {
        /// The base address of the mapped region.
        public let base: Kernel.Memory.Address

        /// The length of the mapped region in bytes.
        public let length: Kernel.File.Size

        #if os(Windows)
            /// The file mapping handle (Windows only).
            ///
            /// This handle must be closed after unmapping the view.
            @usableFromInline
            internal let mappingHandle: HANDLE

            /// Creates a mapped region with the given address, length, and Windows handle.
            @usableFromInline
            internal init(base: Kernel.Memory.Address, length: Kernel.File.Size, mappingHandle: HANDLE) {
                self.base = base
                self.length = length
                self.mappingHandle = mappingHandle
            }
        #else
            /// Creates a mapped region with the given address and length.
            @inlinable
            public init(base: Kernel.Memory.Address, length: Kernel.File.Size) {
                self.base = base
                self.length = length
            }
        #endif
    }
}

// MARK: - Buffer Access

extension Kernel.Memory.Map.Region {
    /// The byte count of this region.
    @inlinable
    public var count: Int { Int(length) }

    /// Calls the given closure with a pointer to the region's bytes.
    ///
    /// - Parameter body: A closure that receives the buffer pointer.
    /// - Returns: The value returned by the closure.
    @inlinable
    public func withUnsafeBytes<R>(
        _ body: (UnsafeRawBufferPointer) throws -> R
    ) rethrows -> R {
        try body(UnsafeRawBufferPointer(start: base.pointer, count: count))
    }

    /// Calls the given closure with a mutable pointer to the region's bytes.
    ///
    /// - Parameter body: A closure that receives the mutable buffer pointer.
    /// - Returns: The value returned by the closure.
    @inlinable
    public func withUnsafeMutableBytes<R>(
        _ body: (UnsafeMutableRawBufferPointer) throws -> R
    ) rethrows -> R {
        try body(UnsafeMutableRawBufferPointer(start: base.mutablePointer, count: count))
    }
}
