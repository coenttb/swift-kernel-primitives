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

extension Kernel.Memory.Shared {
    /// Errors from shared memory syscalls.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// shm_open failed.
        case open(Kernel.Error.Code)

        /// shm_unlink failed.
        case unlink(Kernel.Error.Code)
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Memory.Shared.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .open(let code):
            return "shm_open failed: \(code)"
        case .unlink(let code):
            return "shm_unlink failed: \(code)"
        }
    }
}
