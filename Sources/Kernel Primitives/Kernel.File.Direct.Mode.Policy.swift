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

extension Kernel.File.Direct.Mode {
    /// Policy for automatic mode selection.
    public enum Policy: Sendable, Equatable {
        /// Fall back to buffered I/O if direct is unavailable or alignment fails.
        ///
        /// Behavior by platform:
        /// - **macOS**: Uses `.uncached` (matches intent: avoid cache pollution)
        /// - **Linux/Windows**: Uses `.direct` if requirements known and alignment
        ///   satisfied, otherwise falls back to `.buffered`
        ///
        /// This is the practical choice for portable code.
        case fallbackToBuffered

        /// Error if direct I/O requirements cannot be satisfied.
        ///
        /// Behavior by platform:
        /// - **macOS**: Uses `.uncached` (never errors, since no alignment required)
        /// - **Linux/Windows**: Errors on alignment violation or unknown requirements
        ///
        /// Use when you need cache bypass and want explicit failure on misconfiguration.
        case errorOnViolation
    }
}
