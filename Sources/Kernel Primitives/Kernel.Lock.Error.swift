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
    /// Lock operation errors.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Lock contention - another process holds a conflicting lock.
        /// - POSIX: `EAGAIN` on `F_SETLK` (non-blocking)
        /// - Windows: `ERROR_LOCK_VIOLATION`
        ///
        /// This is only thrown when `wait: false`. Use `try?` pattern:
        /// ```swift
        /// if (try? Kernel.Lock.lock(fd, range: .file, exclusive: true, wait: false)) != nil {
        ///     // Lock acquired
        /// }
        /// ```
        case contention

        /// Deadlock detected.
        /// - POSIX: `EDEADLK`
        ///
        /// The kernel detected that acquiring this lock would cause
        /// a deadlock with another process.
        case deadlock

        /// No locks available - system lock table exhausted.
        /// - POSIX: `ENOLCK`
        ///
        /// This is resource exhaustion, not contention.
        case unavailable
    }
}

extension Kernel.Lock.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .contention: return "lock contention"
        case .deadlock: return "deadlock detected"
        case .unavailable: return "no locks available"
        }
    }
}

extension Kernel.Lock.Error {
    /// Lock acquisition timed out.
    ///
    /// Thrown when `.deadline(...)` acquisition cannot acquire the lock
    /// before the deadline expires.
    public static let timedOut = Self.contention  // Reuse contention semantically

    /// Lock would block (for `.try` acquisition).
    public static let wouldBlock = Self.contention
}
