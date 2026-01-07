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

// MARK: - LockedBox

/// A Sendable box for thread-safe shared state in tests.
///
/// Use this instead of `nonisolated(unsafe)` to maintain
/// proper concurrency safety in tests.
///
/// ## Example
/// ```swift
/// let results = LockedBox<[Int]>([])
/// // In worker thread:
/// results.withLock { $0.append(42) }
/// // In test thread:
/// let values = results.withLock { $0 }
/// ```
public final class LockedBox<T>: @unchecked Sendable {
    private var value: T
    private let lock: Kernel.Thread.Mutex

    public init(_ initial: T) {
        self.value = initial
        self.lock = .init()
    }

    /// Accesses the value under the lock.
    public func withLock<R>(_ body: (inout T) throws -> R) rethrows -> R {
        lock.lock()
        defer { lock.unlock() }
        return try body(&value)
    }
}

// MARK: - Gate

/// A condition-based gate for deterministic synchronization in tests.
///
/// The gate starts closed (by default). One side waits for the gate to open,
/// the other side opens it. No sleeps or polling required.
///
/// ## Example
/// ```swift
/// let gate = Gate()
/// // Worker blocks until gate opens:
/// gate.wait()
/// // Test thread opens gate when ready:
/// gate.open()
/// ```
public final class Gate: @unchecked Sendable {
    private let mutex: Kernel.Thread.Mutex
    private let condition: Kernel.Thread.Condition
    private var isOpen: Bool

    public init(open: Bool = false) {
        self.mutex = .init()
        self.condition = .init()
        self.isOpen = open
    }

    /// Opens the gate, releasing any waiters.
    public func open() {
        mutex.lock()
        isOpen = true
        condition.broadcast()
        mutex.unlock()
    }

    /// Blocks until the gate is opened.
    public func wait() {
        mutex.lock()
        while !isOpen {
            condition.wait(mutex: mutex)
        }
        mutex.unlock()
    }
}

// MARK: - Signal

/// A one-shot signal for deterministic handshakes in tests.
///
/// Used to signal that a condition has been met (e.g., "blocker job has started").
///
/// ## Example
/// ```swift
/// let started = Signal()
/// // Worker signals when it has started:
/// started.signal()
/// // Test thread waits for worker to start:
/// started.wait()
/// ```
public final class Signal: @unchecked Sendable {
    private let mutex: Kernel.Thread.Mutex
    private let condition: Kernel.Thread.Condition
    private var signaled: Bool

    public init() {
        self.mutex = .init()
        self.condition = .init()
        self.signaled = false
    }

    /// Signals that the condition is met.
    public func signal() {
        mutex.lock()
        signaled = true
        condition.broadcast()
        mutex.unlock()
    }

    /// Blocks until signaled.
    public func wait() {
        mutex.lock()
        while !signaled {
            condition.wait(mutex: mutex)
        }
        mutex.unlock()
    }
}
