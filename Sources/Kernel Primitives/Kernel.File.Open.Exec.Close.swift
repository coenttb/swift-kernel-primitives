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

extension Kernel.File.Open.Exec {
    /// Close descriptor options.
    public enum Close: Sendable {
        /// Close the file descriptor on exec.
        ///
        /// - POSIX: `O_CLOEXEC`
        /// - Windows: Non-inheritable handle (default behavior)
        case enabled
    }
}
