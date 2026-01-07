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
    /// Result of a clone operation.
    public enum Result: Sendable, Equatable {
        /// The file was cloned via reflink (zero-copy).
        case reflinked

        /// The file was copied byte-by-byte.
        case copied
    }
}
