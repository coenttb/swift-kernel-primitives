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

extension Kernel.File.Clone.Error {
    /// Raw syscall-level errors for clone operations.
    ///
    /// This type captures the exact errno/win32 error code from syscalls.
    /// It is translated to the semantic `Kernel.File.Clone.Error` at API boundaries.
    public enum Syscall: Swift.Error, Sendable {
        /// Platform syscall failure.
        case platform(code: Kernel.Error.Code, operation: Operation)

        /// Operation not supported.
        case notSupported(operation: Operation)
    }
}
