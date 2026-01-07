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
    /// The behavior policy for clone operations.
    public enum Behavior: Sendable, Equatable {
        /// Attempt reflink only; fail if unsupported.
        ///
        /// Use when you require zero-copy semantics (e.g., for correctness
        /// in snapshot scenarios where sharing storage is intentional).
        case reflinkOrFail

        /// Attempt reflink; fall back to byte-by-byte copy if unsupported.
        ///
        /// This is the practical choice for portable code that wants
        /// best-effort performance optimization.
        case reflinkOrCopy

        /// Skip reflink attempt; always copy bytes.
        ///
        /// Use when you explicitly need independent storage
        /// (e.g., the destination will be heavily modified).
        case copyOnly
    }
}
