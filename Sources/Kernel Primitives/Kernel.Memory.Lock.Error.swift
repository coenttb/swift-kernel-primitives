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

extension Kernel.Memory.Lock {
    /// Errors from page locking syscalls.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// mlock / VirtualLock failed.
        case lock(Kernel.Error.Code)

        /// munlock / VirtualUnlock failed.
        case unlock(Kernel.Error.Code)

        /// mlockall failed (POSIX only).
        case lockAll(Kernel.Error.Code)

        /// munlockall failed (POSIX only).
        case unlockAll(Kernel.Error.Code)
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Memory.Lock.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .lock(let code):
            return "mlock failed: \(code)"
        case .unlock(let code):
            return "munlock failed: \(code)"
        case .lockAll(let code):
            return "mlockall failed: \(code)"
        case .unlockAll(let code):
            return "munlockall failed: \(code)"
        }
    }
}
