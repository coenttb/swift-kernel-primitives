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

extension Kernel.IO {
    /// Blocking domain - non-blocking operation semantics.
    ///
    /// When a descriptor is in non-blocking mode and an operation
    /// cannot complete immediately, these errors are returned.
    public enum Blocking: Sendable {

    }
}
