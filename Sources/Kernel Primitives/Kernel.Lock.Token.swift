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

#if os(Windows)
    public import WinSDK
#else
    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        public import Glibc
    #elseif canImport(Musl)
        public import Musl
    #endif
#endif

extension Kernel.Lock {
    /// A move-only token representing a held file lock.
    ///
    /// `Token` ensures the lock is released when it goes out of scope.
    /// It is `~Copyable` to prevent accidental duplication of lock ownership.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let token = try Kernel.Lock.Token(
    ///     descriptor: fd,
    ///     range: .file,
    ///     kind: .exclusive
    /// )
    /// defer { token.release() }
    ///
    /// // ... use the locked file ...
    /// ```
    ///
    /// ## Lifetime
    ///
    /// - `release()` is the canonical way to release the lock
    /// - `deinit` releases the lock as a backstop (correctness should not depend on this)
    /// - Once released, the token cannot be used
    ///
    /// ## Thread Safety
    ///
    /// Token stores a `Kernel.Descriptor` which is conditionally `Sendable`.
    /// The mutable `isReleased` state is safe because `~Copyable` ensures
    /// single ownership - only one thread can own the token at a time.
    public struct Token: ~Copyable {
        private let descriptor: Kernel.Descriptor
        private let range: Range
        private var isReleased: Bool

        /// Creates a lock token by acquiring a lock.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor.
        ///   - range: The byte range to lock.
        ///   - kind: The lock kind (shared or exclusive).
        ///   - acquire: The acquisition strategy (default: `.wait`).
        /// - Throws: `Kernel.Lock.Error` if locking fails.
        public init(
            descriptor: Kernel.Descriptor,
            range: Kernel.Lock.Range = .file,
            kind: Kernel.Lock.Kind,
            acquire: Kernel.Lock.Acquire = .wait
        ) throws(Kernel.Lock.Error) {
            self.descriptor = descriptor
            self.range = range
            self.isReleased = false

            try Self.acquireLock(
                descriptor: descriptor,
                range: range,
                kind: kind,
                acquire: acquire
            )
        }

        /// Releases the lock.
        ///
        /// On success, the token is marked released and subsequent calls are no-ops.
        /// On failure, the token remains valid for retry - the lock is preserved.
        ///
        /// - Throws: `Kernel.Lock.Error` if the unlock syscall fails.
        public mutating func release() throws(Kernel.Lock.Error) {
            guard !isReleased else { return }
            try Kernel.Lock.unlock(descriptor, range: range)
            isReleased = true
        }

        deinit {
            // Backstop release - correctness should not depend on this
            guard !isReleased else { return }
            _ = Result { try Kernel.Lock.unlock(descriptor, range: range) }
        }
    }
}

// MARK: - Token Sendable

#if os(Windows)
    // On Windows, Kernel.Descriptor uses @unchecked Sendable.
    // Token's mutable isReleased is safe because ~Copyable ensures single ownership.
    extension Kernel.Lock.Token: @unchecked Sendable {}
#else
    extension Kernel.Lock.Token: Sendable {}
#endif

// MARK: - Token Acquisition Logic

extension Kernel.Lock.Token {
    /// Acquires a lock using the specified strategy.
    private static func acquireLock(
        descriptor: Kernel.Descriptor,
        range: Kernel.Lock.Range,
        kind: Kernel.Lock.Kind,
        acquire: Kernel.Lock.Acquire
    ) throws(Kernel.Lock.Error) {
        switch acquire {
        case .try:
            let acquired = try Kernel.Lock.tryLock(descriptor, range: range, kind: kind)
            if !acquired {
                throw .contention
            }

        case .wait:
            try Kernel.Lock.lock(descriptor, range: range, kind: kind)

        case .deadline(let deadline):
            try acquireWithDeadline(
                descriptor: descriptor,
                range: range,
                kind: kind,
                deadline: deadline
            )
        }
    }

    /// Polls for a lock until the deadline expires.
    ///
    /// Uses exponential backoff starting at 1ms, capped at 100ms.
    private static func acquireWithDeadline(
        descriptor: Kernel.Descriptor,
        range: Kernel.Lock.Range,
        kind: Kernel.Lock.Kind,
        deadline: ContinuousClock.Instant
    ) throws(Kernel.Lock.Error) {
        var backoff: Duration = .milliseconds(1)
        let maxBackoff: Duration = .milliseconds(100)

        while true {
            // Check deadline first
            let now = ContinuousClock.now
            if now >= deadline {
                throw .contention
            }

            // Try to acquire
            let acquired = try Kernel.Lock.tryLock(descriptor, range: range, kind: kind)

            if acquired {
                // Critical: re-check deadline after acquisition
                // If deadline passed, unlock and throw to maintain invariant:
                // "success means lock was acquired before deadline"
                if ContinuousClock.now >= deadline {
                    try? Kernel.Lock.unlock(descriptor, range: range)
                    throw .contention
                }
                return
            }

            // Calculate sleep time (don't overshoot deadline)
            let remaining = deadline - ContinuousClock.now
            if remaining <= .zero {
                throw .contention
            }

            let sleepDuration = min(backoff, remaining)
            sleep(sleepDuration)

            // Exponential backoff with cap
            backoff = min(backoff * 2, maxBackoff)
        }
    }

    /// Platform-specific sleep without Foundation dependency.
    private static func sleep(_ duration: Duration) {
        let (seconds, attoseconds) = duration.components
        let nanoseconds = UInt64(seconds) * 1_000_000_000 + UInt64(attoseconds) / 1_000_000_000

        #if os(Windows)
            let milliseconds = nanoseconds / 1_000_000
            Sleep(DWORD(min(milliseconds, UInt64(DWORD.max))))
        #else
            var ts = timespec()
            ts.tv_sec = Int(nanoseconds / 1_000_000_000)
            ts.tv_nsec = Int(nanoseconds % 1_000_000_000)
            nanosleep(&ts, nil)
        #endif
    }
}

// MARK: - Scoped Locking Helpers

extension Kernel.Lock {
    /// Executes a closure while holding an exclusive lock.
    ///
    /// The lock is automatically released when the closure completes.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - range: The byte range to lock (default: whole file).
    ///   - acquire: The acquisition strategy (default: `.wait`).
    ///   - body: The closure to execute while holding the lock.
    /// - Returns: The result of the closure.
    /// - Throws: `Kernel.Lock.Error` if locking fails, or rethrows from the closure.
    public static func withExclusive<T>(
        _ descriptor: Kernel.Descriptor,
        range: Range = .file,
        acquire: Acquire = .wait,
        _ body: () throws -> T
    ) throws -> T {
        var token = try Token(descriptor: descriptor, range: range, kind: .exclusive, acquire: acquire)
        defer { try? token.release() }
        return try body()
    }

    /// Executes a closure while holding a shared lock.
    ///
    /// The lock is automatically released when the closure completes.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - range: The byte range to lock (default: whole file).
    ///   - acquire: The acquisition strategy (default: `.wait`).
    ///   - body: The closure to execute while holding the lock.
    /// - Returns: The result of the closure.
    /// - Throws: `Kernel.Lock.Error` if locking fails, or rethrows from the closure.
    public static func withShared<T>(
        _ descriptor: Kernel.Descriptor,
        range: Range = .file,
        acquire: Acquire = .wait,
        _ body: () throws -> T
    ) throws -> T {
        var token = try Token(descriptor: descriptor, range: range, kind: .shared, acquire: acquire)
        defer { try? token.release() }
        return try body()
    }
}
