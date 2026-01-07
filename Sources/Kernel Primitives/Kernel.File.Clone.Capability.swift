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

extension Kernel.File.Clone {
    /// The cloning capability of a filesystem/path.
    ///
    /// Capability is probed per-path because:
    /// - Different volumes may have different capabilities
    /// - The same process may work with multiple filesystems
    public enum Capability: Sendable, Equatable {
        /// The filesystem supports copy-on-write reflink.
        ///
        /// Cloning is O(1) regardless of file size.
        case reflink

        /// The filesystem does not support reflink.
        ///
        /// Only byte-by-byte copy is available.
        case none
    }
}
