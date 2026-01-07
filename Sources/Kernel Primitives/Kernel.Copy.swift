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
    /// File copy operations using kernel-accelerated mechanisms.
    ///
    /// Provides access to platform-native copy operations that can be significantly
    /// faster than userspace read/write loops. On supported filesystems, these
    /// operations may use copy-on-write (reflink) semantics, avoiding actual data
    /// copying until modification.
    ///
    /// ## Platform Support
    ///
    /// | Platform | Mechanism | CoW Support |
    /// |----------|-----------|-------------|
    /// | macOS | `clonefile()` | APFS only |
    /// | Linux | `copy_file_range()` | Btrfs, XFS, etc. |
    /// | Windows | `CopyFileEx()` | ReFS only |
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Copy a file (uses best available mechanism)
    /// try Kernel.Copy.copy(from: sourcePath, to: destPath)
    ///
    /// // Clone if possible (fails if not supported)
    /// try Kernel.Copy.clone(from: sourcePath, to: destPath)
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``Kernel/File/Clone``
    public enum Copy: Sendable {

    }
}
