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

extension Kernel.File.Stats.Kind {
    /// Link types.
    public enum Link: Sendable, Equatable, Hashable {
        /// Symbolic link.
        case symbolic

        /// Junction or mount point (Windows only).
        ///
        /// On Windows, junctions and mount points are reparse points with
        /// `IO_REPARSE_TAG_MOUNT_POINT`. They behave like directory symlinks
        /// but have different semantics (junctions are always absolute paths).
        case junction
    }
}
