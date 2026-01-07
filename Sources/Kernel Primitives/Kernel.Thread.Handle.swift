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
    public import Darwin
#elseif canImport(Glibc)
    public import Glibc
#elseif os(Windows)
    public import WinSDK
#endif

extension Kernel.Thread {
    /// Opaque handle to an OS thread.
    ///
    /// ## Move-Only Semantics
    /// This type is `~Copyable` to enforce exactly-once `join()` semantics.
    /// Copying the handle would allow double-join, which is undefined behavior
    /// on all platforms (double `CloseHandle` on Windows, double `pthread_join` on POSIX).
    ///
    /// ## Safety
    /// This type is `@unchecked Sendable` because the underlying handle
    /// (pthread_t or HANDLE) can be safely passed between threads.
    /// The move-only constraint ensures exactly-once consumption.
    public struct Handle: ~Copyable, @unchecked Sendable {
        #if os(Windows)
            @usableFromInline
            let rawValue: HANDLE

            /// Creates a handle from a Windows HANDLE.
            @inlinable
            public init(rawValue: HANDLE) {
                self.rawValue = rawValue
            }
        #else
            @usableFromInline
            let rawValue: pthread_t

            /// Creates a handle from a pthread_t.
            @inlinable
            public init(rawValue: pthread_t) {
                self.rawValue = rawValue
            }
        #endif
    }
}

// MARK: - Handle Operations

extension Kernel.Thread.Handle {
    /// Waits for the thread to complete and releases the handle.
    ///
    /// This is a consuming operation - the handle cannot be used after calling `join()`.
    /// On Windows, this calls `WaitForSingleObject` then `CloseHandle`.
    /// On POSIX, this calls `pthread_join`.
    ///
    /// - Precondition: Must NOT be called from the same thread (deadlock).
    /// - Note: Must be called exactly once. The `~Copyable` constraint enforces this.
    @inlinable
    public consuming func join() {
        #if os(Windows)
            _ = WaitForSingleObject(rawValue, INFINITE)
            _ = CloseHandle(rawValue)
        #else
            _ = pthread_join(rawValue, nil)
        #endif
    }

    /// Detaches the thread, allowing it to run independently.
    ///
    /// After detaching, resources are automatically cleaned up when the thread exits.
    /// This is a consuming operation - the handle cannot be used after calling `detach()`.
    ///
    /// - Note: On Windows, this closes the handle immediately (thread continues running).
    ///   On POSIX, this calls `pthread_detach`.
    @inlinable
    public consuming func detach() {
        #if os(Windows)
            _ = CloseHandle(rawValue)
        #else
            _ = pthread_detach(rawValue)
        #endif
    }

    /// Check if this handle refers to the current thread.
    ///
    /// Used for shutdown safety to prevent join-on-self deadlock.
    @inlinable
    public var isCurrent: Bool {
        #if os(Windows)
            GetCurrentThreadId() == GetThreadId(rawValue)
        #else
            pthread_equal(pthread_self(), rawValue) != 0
        #endif
    }
}
