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

extension Kernel {
    /// File-related types and operations.
    public enum File {}
}

extension Kernel.File {
    /// A file descriptor.
    ///
    /// Typealias to `Kernel.Descriptor` for semantic clarity within the File namespace.
    public typealias Descriptor = Kernel.Descriptor
}

extension Kernel.File {
    /// Phantom type tag for the file byte space.
    ///
    /// Used to parameterize Dimension types for file I/O operations,
    /// providing type-safe dimensional arithmetic:
    /// - `Offset - Offset = Delta` (difference between positions)
    /// - `Offset + Delta = Offset` (translate position)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let start: Kernel.File.Offset = 1000
    /// let end: Kernel.File.Offset = 5000
    /// let distance = end - start  // Delta (4000)
    /// let next = end + distance   // Offset (9000)
    /// ```
    public enum Space {}
}
