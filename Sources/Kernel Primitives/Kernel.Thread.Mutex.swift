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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif os(Windows)
    public import WinSDK
#endif

extension Kernel.Thread {
    /// A low-level mutex for thread synchronization.
    ///
    /// This is a policy-free wrapper around platform mutex primitives:
    /// - POSIX: `pthread_mutex_t`
    /// - Windows: `SRWLOCK`
    ///
    /// ## Threading
    /// - **lock()**: Blocks the calling thread until the mutex is available
    /// - **tryLock()**: Returns immediately with success/failure, never blocks
    /// - **unlock()**: Must be called from the thread that acquired the lock
    ///
    /// ## Cancellation
    /// Mutex operations are not cancellation points. A thread blocked on `lock()`
    /// cannot be cancelled until it acquires the mutex.
    ///
    /// ## Scheduling
    /// No fairness guarantees. Under contention, lock acquisition order is
    /// platform-dependent and may not be FIFO.
    ///
    /// ## Safety
    /// This type is `@unchecked Sendable` because it provides internal synchronization.
    /// The mutex itself is what makes cross-thread access safe.
    ///
    /// ## Usage
    /// ```swift
    /// let mutex = Kernel.Thread.Mutex()
    /// mutex.lock()
    /// defer { mutex.unlock() }
    /// // ... critical section ...
    /// ```
    ///
    /// For scoped locking, use `withLock`:
    /// ```swift
    /// let result = mutex.withLock {
    ///     // ... critical section ...
    ///     return someValue
    /// }
    /// ```
    public final class Mutex: @unchecked Sendable {
        #if os(Windows)
            private var srwlock: SRWLOCK

            /// Creates a new mutex.
            public init() {
                self.srwlock = SRWLOCK()
                InitializeSRWLock(&srwlock)
            }

        // SRWLOCK doesn't need destruction on Windows
        #else
            private var mutex: pthread_mutex_t

            /// Creates a new mutex.
            public init() {
                self.mutex = pthread_mutex_t()
                var attr = pthread_mutexattr_t()
                pthread_mutexattr_init(&attr)
                pthread_mutex_init(&self.mutex, &attr)
                pthread_mutexattr_destroy(&attr)
            }

            deinit {
                pthread_mutex_destroy(&mutex)
            }
        #endif
    }
}

// MARK: - Lock Operations

extension Kernel.Thread.Mutex {
    /// Acquires the mutex, blocking until available.
    ///
    /// ## Threading
    /// Blocks the calling thread until the mutex becomes available. The blocked
    /// thread yields its CPU time to other threads.
    ///
    /// ## Deadlock
    /// Calling `lock()` on a mutex already held by the current thread causes
    /// **deadlock** (the thread waits forever). Use `tryLock()` if you need
    /// to check ownership, or use a recursive mutex implementation if needed.
    ///
    /// ## Cancellation
    /// This is not a cancellation point. A blocked thread cannot be cancelled
    /// until it successfully acquires the mutex.
    public func lock() {
        #if os(Windows)
            AcquireSRWLockExclusive(&srwlock)
        #else
            pthread_mutex_lock(&mutex)
        #endif
    }

    /// Releases the mutex, allowing other threads to acquire it.
    ///
    /// ## Precondition
    /// The mutex **must** be held by the current thread. Calling `unlock()` on
    /// a mutex not held by the current thread is **undefined behavior**:
    /// - May silently corrupt internal state
    /// - May cause other threads to deadlock or crash
    /// - Behavior is platform-specific and unpredictable
    public func unlock() {
        #if os(Windows)
            ReleaseSRWLockExclusive(&srwlock)
        #else
            pthread_mutex_unlock(&mutex)
        #endif
    }

    /// Attempts to acquire the mutex without blocking.
    ///
    /// ## Threading
    /// Never blocks. Returns immediately regardless of mutex state.
    ///
    /// ## Return Value
    /// - `true`: Mutex was successfully acquired. Caller must call `unlock()`.
    /// - `false`: Mutex is held by another thread. No action needed.
    ///
    /// - Returns: `true` if the mutex was acquired, `false` if it was already held.
    public func tryLock() -> Bool {
        #if os(Windows)
            return TryAcquireSRWLockExclusive(&srwlock) != 0
        #else
            return pthread_mutex_trylock(&mutex) == 0
        #endif
    }

    /// Executes a closure while holding the mutex.
    ///
    /// The mutex is automatically acquired before and released after the closure.
    ///
    /// - Parameter body: The closure to execute while holding the mutex.
    /// - Returns: The value returned by the closure.
    /// - Throws: Any error thrown by `body`.
    public func withLock<T, E: Error>(_ body: () throws(E) -> T) throws(E) -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}

// MARK: - Internal Access for Condition

extension Kernel.Thread.Mutex {
    /// Provides access to the underlying platform mutex pointer.
    ///
    /// This is internal API for `Kernel.Thread.Condition` to use when waiting.
    /// - Parameter body: A closure that receives the pointer.
    /// - Returns: The value returned by `body`.
    #if os(Windows)
        func withUnsafeMutablePointer<T>(_ body: (UnsafeMutablePointer<SRWLOCK>) -> T) -> T {
            Swift.withUnsafeMutablePointer(to: &srwlock, body)
        }
    #else
        func withUnsafeMutablePointer<T>(_ body: (UnsafeMutablePointer<pthread_mutex_t>) -> T) -> T {
            Swift.withUnsafeMutablePointer(to: &mutex, body)
        }
    #endif
}
