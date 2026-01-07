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

extension Kernel.File.Open {
    /// Cache behavior options.
    public enum Cache: Sendable {
        /// Disable caching (macOS only).
        ///
        /// - macOS: `F_NOCACHE` via `fcntl` after open
        /// - Other platforms: Ignored
        ///
        /// - Note: This is a weaker hint than `.direct` on macOS.
        case disabled
    }
}
