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

import Kernel_Primitives

/// Test harness utilities for threading tests.
///
/// Provides a condvar-based coordination mechanism that eliminates:
/// - Cross-thread mutex unlock (undefined behavior)
/// - Data races on shared state
/// - Timing-based correctness assertions
///
/// Use `Harness<State>` to coordinate between test threads via:
/// - `update { }` for synchronized mutation plus broadcast
/// - `wait(until:)` for deterministic ordering
/// - `withLocked { }` for synchronized reads
public enum KernelThreadTest {
    /// Timeout error for `wait(until:)` operations.
    ///
    /// This is only used as a deadlock guard, not as a correctness signal.
    public struct Timeout: Swift.Error, Sendable, Equatable {
        public init() {}
    }

    /// Thread-safe state container with condvar-based signaling.
    ///
    /// Use this to coordinate between threads in tests without data races
    /// or cross-thread mutex unlock.
    ///
    /// ## Example
    /// ```swift
    /// struct State {
    ///     var workerStarted = false
    ///     var result: Bool? = nil
    /// }
    /// let h = KernelThreadTest.Harness(State())
    ///
    /// // Worker thread
    /// h.update { $0.workerStarted = true }
    /// let ok = someOperation()
    /// h.update { $0.result = ok }
    ///
    /// // Main thread
    /// try h.wait(until: { $0.workerStarted })
    /// try h.wait(until: { $0.result != nil })
    /// let result = h.withLocked { $0.result }
    /// ```
    public final class Harness<State>: @unchecked Sendable {
        private let mutex: Kernel.Thread.Mutex
        private let condition: Kernel.Thread.Condition
        private var state: State

        /// Creates a harness with the given initial state.
        public init(_ initial: State) {
            self.mutex = Kernel.Thread.Mutex()
            self.condition = Kernel.Thread.Condition()
            self.state = initial
        }

        /// Executes a closure with exclusive access to the state.
        ///
        /// Does not signal waiting threads. Use `update` if you need to signal.
        public func withLocked<R>(_ body: (inout State) -> R) -> R {
            mutex.lock()
            defer { mutex.unlock() }
            return body(&state)
        }

        /// Mutates the state and broadcasts to all waiting threads.
        ///
        /// Use this when changing state that other threads may be waiting on.
        public func update(_ body: (inout State) -> Void) {
            mutex.lock()
            body(&state)
            condition.broadcast()
            mutex.unlock()
        }

        /// Broadcasts to waiting threads without modifying state.
        public func signal() {
            mutex.lock()
            condition.broadcast()
            mutex.unlock()
        }

        /// Waits until the predicate returns true, with a timeout.
        ///
        /// The timeout is only a deadlock guard. Tests should not rely on
        /// timing for correctness; use ordering via `update`/`wait`.
        ///
        /// - Parameters:
        ///   - predicate: Condition to wait for.
        ///   - timeoutSeconds: Maximum time to wait (default 5 seconds).
        /// - Throws: `Timeout` if the predicate is not satisfied within the timeout.
        public func wait(
            until predicate: (State) -> Bool,
            timeoutSeconds: Int = 5
        ) throws(Timeout) {
            mutex.lock()
            defer { mutex.unlock() }

            if predicate(state) { return }

            let timeout = Duration.seconds(timeoutSeconds)

            while !predicate(state) {
                let signaled = condition.wait(mutex: mutex, timeout: timeout)
                if !signaled { throw Timeout() }
            }
        }
    }
}
