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

extension Kernel.Lock {
    /// Lock acquisition strategy.
    public enum Acquire: Sendable, Equatable {
        /// Try once without blocking. Returns immediately.
        case `try`

        /// Wait indefinitely until the lock is available.
        case wait

        /// Wait until the deadline, polling with exponential backoff.
        ///
        /// - Parameter deadline: The absolute time by which the lock must be acquired.
        case deadline(ContinuousClock.Instant)

        /// Creates a deadline-based acquisition from a duration.
        ///
        /// - Parameter timeout: The maximum time to wait.
        /// - Returns: An acquisition strategy with a deadline.
        public static func timeout(_ duration: Duration) -> Acquire {
            .deadline(ContinuousClock.now.advanced(by: duration))
        }
    }
}
