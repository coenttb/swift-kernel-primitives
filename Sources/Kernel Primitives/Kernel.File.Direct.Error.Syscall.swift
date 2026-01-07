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

extension Kernel.File.Direct.Error {
    /// Raw syscall-level error with platform-specific details.
    ///
    /// This type captures the exact errno/win32 error code from syscalls.
    /// It is translated to the semantic `Kernel.File.Direct.Error` at API boundaries.
    package enum Syscall: Swift.Error, Sendable, Equatable {
        /// Platform syscall failure.
        case platform(code: Kernel.Error.Code, operation: Operation)

        /// Invalid file descriptor provided.
        case invalidDescriptor(operation: Operation)

        /// Alignment validation failed.
        case alignmentViolation(operation: Operation)

        /// Operation not supported on this platform/filesystem.
        case notSupported(operation: Operation)
    }
}
