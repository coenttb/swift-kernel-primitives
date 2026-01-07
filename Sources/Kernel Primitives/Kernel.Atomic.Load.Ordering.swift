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

extension Kernel.Atomic.Load {
    /// Ordering semantics for load operations.
    public enum Ordering: Sendable {
        /// No ordering guarantees.
        case relaxed

        /// Acquire semantics: subsequent reads/writes cannot be reordered before this load.
        case acquiring
    }
}
