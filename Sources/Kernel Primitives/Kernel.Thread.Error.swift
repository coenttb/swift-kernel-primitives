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

extension Kernel.Thread {
    /// Errors from thread operations.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Thread creation failed.
        ///
        /// - On POSIX: The return value from `pthread_create` (e.g., EAGAIN, EPERM).
        /// - On Windows: The value from `GetLastError()`.
        case create(Kernel.Error.Code)

        /// Thread join failed.
        case join(Kernel.Error.Code)

        /// Thread detach failed.
        case detach(Kernel.Error.Code)
    }
}

extension Kernel.Thread.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .create(let code):
            return "Thread creation failed: \(code)"
        case .join(let code):
            return "Thread join failed: \(code)"
        case .detach(let code):
            return "Thread detach failed: \(code)"
        }
    }
}

