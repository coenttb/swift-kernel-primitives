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
    /// A low-level condition variable for thread synchronization.
    ///
    /// This is a policy-free wrapper around platform condition variable primitives:
    /// - POSIX: `pthread_cond_t`
    /// - Windows: `CONDITION_VARIABLE`
    ///
    /// ## Safety
    /// This type is `@unchecked Sendable` because it provides internal synchronization.
    ///
    /// ## Usage
    /// Condition variables are always used with a mutex:
    /// ```swift
    /// let mutex = Kernel.Thread.Mutex()
    /// let condition = Kernel.Thread.Condition()
    ///
    /// // Waiting thread:
    /// mutex.lock()
    /// while !ready {
    ///     condition.wait(mutex: mutex)
    /// }
    /// // ... process ...
    /// mutex.unlock()
    ///
    /// // Signaling thread:
    /// mutex.lock()
    /// ready = true
    /// condition.signal()
    /// mutex.unlock()
    /// ```
    public final class Condition: @unchecked Sendable {
        #if os(Windows)
            private var condvar: CONDITION_VARIABLE

            /// Creates a new condition variable.
            public init() {
                self.condvar = CONDITION_VARIABLE()
                InitializeConditionVariable(&condvar)
            }

        // CONDITION_VARIABLE doesn't need destruction on Windows
        #else
            private var cond: pthread_cond_t

            /// Creates a new condition variable.
            ///
            /// On Linux, configures the condition to use `CLOCK_MONOTONIC` for
            /// timed waits, which is more robust than `CLOCK_REALTIME`.
            public init() {
                self.cond = pthread_cond_t()
                var attr = pthread_condattr_t()
                pthread_condattr_init(&attr)
                #if !os(macOS) && !os(iOS) && !os(tvOS) && !os(watchOS)
                    pthread_condattr_setclock(&attr, CLOCK_MONOTONIC)
                #endif
                pthread_cond_init(&self.cond, &attr)
                pthread_condattr_destroy(&attr)
            }

            deinit {
                pthread_cond_destroy(&cond)
            }
        #endif
    }
}

// MARK: - Wait Operations

extension Kernel.Thread.Condition {
    /// Waits on the condition variable.
    ///
    /// The mutex is atomically released while waiting and reacquired before returning.
    ///
    /// - Parameter mutex: The mutex to release while waiting.
    /// - Precondition: The mutex must be held by the current thread.
    public func wait(mutex: Kernel.Thread.Mutex) {
        #if os(Windows)
            _ = mutex.withUnsafeMutablePointer { mutexPtr in
                SleepConditionVariableSRW(&condvar, mutexPtr, INFINITE, 0)
            }
        #else
            _ = mutex.withUnsafeMutablePointer { mutexPtr in
                pthread_cond_wait(&cond, mutexPtr)
            }
        #endif
    }

    /// Waits on the condition variable with a timeout.
    ///
    /// The mutex is atomically released while waiting and reacquired before returning.
    ///
    /// - Parameters:
    ///   - mutex: The mutex to release while waiting.
    ///   - timeout: Maximum time to wait.
    /// - Returns: `true` if signaled, `false` if timed out.
    /// - Precondition: The mutex must be held by the current thread.
    public func wait(mutex: Kernel.Thread.Mutex, timeout: Duration) -> Bool {
        mutex.withUnsafeMutablePointer { mutexPtr in
            #if os(Windows)
                let ms = timeout.milliseconds
                return SleepConditionVariableSRW(&condvar, mutexPtr, DWORD(ms), 0)
            #else
                var ts = timespec()
                #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
                    // macOS uses absolute time from gettimeofday
                    var tv = timeval()
                    gettimeofday(&tv, nil)
                    ts.tv_sec = tv.tv_sec + Int(timeout.seconds)
                    ts.tv_nsec = Int(tv.tv_usec) * 1000 + Int(timeout.nanoseconds)
                    if ts.tv_nsec >= 1_000_000_000 {
                        ts.tv_sec += 1
                        ts.tv_nsec -= 1_000_000_000
                    }
                #else
                    // Linux uses CLOCK_MONOTONIC (set in init)
                    clock_gettime(CLOCK_MONOTONIC, &ts)
                    ts.tv_sec += Int(timeout.seconds)
                    ts.tv_nsec += Int(timeout.nanoseconds)
                    if ts.tv_nsec >= 1_000_000_000 {
                        ts.tv_sec += 1
                        ts.tv_nsec -= 1_000_000_000
                    }
                #endif
                let result = pthread_cond_timedwait(&cond, mutexPtr, &ts)
                return result == 0
            #endif
        }
    }

}

// MARK: - Signal Operations

extension Kernel.Thread.Condition {
    /// Signals one waiting thread.
    ///
    /// If multiple threads are waiting, one is unblocked (which one is unspecified).
    public func signal() {
        #if os(Windows)
            WakeConditionVariable(&condvar)
        #else
            pthread_cond_signal(&cond)
        #endif
    }

    /// Signals all waiting threads.
    ///
    /// All threads waiting on this condition variable are unblocked.
    public func broadcast() {
        #if os(Windows)
            WakeAllConditionVariable(&condvar)
        #else
            pthread_cond_broadcast(&cond)
        #endif
    }
}

// MARK: - Duration Helpers

extension Duration {
    /// Total seconds component.
    @usableFromInline
    var seconds: Int64 {
        let (s, _) = components
        return s
    }

    /// Nanoseconds component (0..<1_000_000_000).
    @usableFromInline
    var nanoseconds: Int64 {
        let (_, atto) = components
        return atto / 1_000_000_000
    }

    /// Total milliseconds.
    @usableFromInline
    var milliseconds: Int64 {
        let (s, atto) = components
        return s * 1000 + atto / 1_000_000_000_000_000
    }
}
