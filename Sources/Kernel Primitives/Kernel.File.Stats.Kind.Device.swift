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
    /// Device types.
    public enum Device: Sendable, Equatable, Hashable {
        /// Block device.
        case block

        /// Character device.
        case character
    }
}
