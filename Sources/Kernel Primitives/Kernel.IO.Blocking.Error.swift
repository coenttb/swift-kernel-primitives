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

extension Kernel.IO.Blocking {
    /// Blocking-related errors.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Operation would block on a non-blocking descriptor.
        /// - POSIX: `EAGAIN`, `EWOULDBLOCK`
        ///
        /// The caller should wait for the descriptor to become ready
        /// (e.g., via poll/select/kqueue/epoll) and retry.
        case wouldBlock
    }
}

// MARK: - CustomStringConvertible

extension Kernel.IO.Blocking.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .wouldBlock:
            return "operation would block"
        }
    }
}
