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
    /// Acquires the mutex.
    ///
    /// Blocks until the mutex is available.
    public func lock() {
        #if os(Windows)
            AcquireSRWLockExclusive(&srwlock)
        #else
            pthread_mutex_lock(&mutex)
        #endif
    }

    /// Releases the mutex.
    ///
    /// - Precondition: The mutex must be held by the current thread.
    public func unlock() {
        #if os(Windows)
            ReleaseSRWLockExclusive(&srwlock)
        #else
            pthread_mutex_unlock(&mutex)
        #endif
    }

    /// Attempts to acquire the mutex without blocking.
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
