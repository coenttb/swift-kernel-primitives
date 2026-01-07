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

public import Dimension

extension Kernel.File.System {
    /// File/inode namespace for filesystem statistics.
    public enum File {}
}

extension Kernel.File.System.File {
    /// Count of files (inodes) in a filesystem.
    ///
    /// Used for total file count and free file count in `File.System.Stats`.
    public typealias Count = Tagged<Kernel.File.System.File, UInt64>
}
