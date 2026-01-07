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

extension Kernel.System {
    /// Path-related types.
    public enum Path {}
}

// MARK: - Path.Length

extension Kernel.System.Path {
    /// Maximum path length in bytes.
    ///
    /// A type-safe wrapper for the platform's maximum path length.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let maxLen = Kernel.System.path.max
    /// guard path.count <= Int(maxLen) else {
    ///     throw PathTooLongError()
    /// }
    /// ```
    public typealias Length = Tagged<Kernel.System.Path, Int>
}

// MARK: - Int Conversion

extension Int {
    /// Creates an Int from a path length for comparison.
    @inlinable
    public init(_ length: Kernel.System.Path.Length) {
        self = length.rawValue
    }
}
