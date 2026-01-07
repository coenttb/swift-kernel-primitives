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
    /// Namespace for error-related types and utilities.
    ///
    /// This namespace contains:
    /// - `Code`: Unified error codes (POSIX errno, Win32 error codes)
    /// - `Number`: Platform-specific error number wrapper
    /// - `Unmapped`: Container for unmapped platform errors
    ///
    /// For the unified error type that aggregates all domain errors,
    /// see `Kernel.Failure`.
    public enum Error {}
}
