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

extension Kernel.File.Open {
    /// Blocking behavior options.
    public enum Blocking: Sendable {
        /// Disable blocking I/O.
        ///
        /// - POSIX: `O_NONBLOCK`
        /// - Windows: Requires async I/O with OVERLAPPED structures
        ///
        /// - Note: This flag is primarily for POSIX. On Windows, non-blocking
        ///   semantics require a different I/O model (IOCP).
        case disabled
    }
}
