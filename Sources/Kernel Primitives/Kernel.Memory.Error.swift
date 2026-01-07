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

extension Kernel.Memory {
    /// Memory-related errors.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Bad address - pointer outside accessible address space.
        /// - POSIX: `EFAULT`
        ///
        /// This typically indicates a programming error where
        /// an invalid buffer pointer was passed to a syscall.
        case fault

        /// Not enough memory available.
        /// - POSIX: `ENOMEM`
        /// - Windows: `ERROR_NOT_ENOUGH_MEMORY`
        case exhausted
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Memory.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .fault:
            return "bad address"
        case .exhausted:
            return "out of memory"
        }
    }
}
