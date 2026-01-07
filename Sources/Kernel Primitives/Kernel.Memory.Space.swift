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

extension Kernel.Memory {
    /// Phantom type distinguishing memory address space.
    ///
    /// Used with `Binary.Position` to create type-safe memory addresses
    /// that participate in dimensional arithmetic and alignment checking.
    public enum Space {}
}
