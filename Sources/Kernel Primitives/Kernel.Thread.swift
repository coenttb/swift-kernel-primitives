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

extension Kernel {
    /// Raw thread syscall wrappers.
    ///
    /// This namespace provides policy-free wrappers for platform thread primitives:
    /// - POSIX: `pthread_create`, `pthread_join`, `pthread_detach`
    /// - Windows: `CreateThread`, `WaitForSingleObject`, `CloseHandle`
    ///
    /// Higher layers (swift-io) build thread spawning APIs, ownership transfer,
    /// and lifecycle management on top of these primitives.
    public enum Thread {}
}

#if canImport(Darwin)
    public import Darwin
#elseif canImport(Glibc)
    public import Glibc
#elseif os(Windows)
    public import WinSDK
#endif

// MARK: - Create

extension Kernel.Thread {
    /// Creates a new OS thread.
    ///
    /// This is the low-level thread creation syscall wrapper. The closure
    /// is invoked exactly once on the spawned OS thread.
    ///
    /// - Parameter body: The work to run on the new thread.
    /// - Returns: A handle to the created thread.
    /// - Throws: `Error.create` if thread creation fails.
    ///
    /// - Note: The caller is responsible for memory management of any context
    ///   passed to the closure. For ownership transfer patterns, see swift-io's
    ///   higher-level `IO.Thread.spawn` API.
    @inlinable
    public static func create(
        _ body: @escaping @Sendable () -> Void
    ) throws(Error) -> Handle {
        let context = UnsafeMutablePointer<(@Sendable () -> Void)>.allocate(capacity: 1)
        context.initialize(to: body)

        #if os(Windows)
            let handle = CreateThread(
                nil,
                0,
                { ctx in
                    guard let ctx else { return 0 }
                    let bodyPtr = ctx.assumingMemoryBound(to: (@Sendable () -> Void).self)
                    let work = bodyPtr.move()
                    bodyPtr.deallocate()
                    work()
                    return 0
                },
                context,
                0,
                nil
            )

            guard let handle else {
                context.deinitialize(count: 1)
                context.deallocate()
                throw .create(.captureLastError())
            }

            return Handle(rawValue: handle)

        #elseif canImport(Darwin)
            var thread: pthread_t?

            let result = pthread_create(
                &thread,
                nil,
                { ctx in
                    let bodyPtr = ctx.assumingMemoryBound(to: (@Sendable () -> Void).self)
                    let work = bodyPtr.move()
                    bodyPtr.deallocate()
                    work()
                    return nil
                },
                context
            )

            guard result == 0, let thread else {
                context.deinitialize(count: 1)
                context.deallocate()
                throw .create(.posix(result))
            }

            return Handle(rawValue: thread)

        #else
            // Linux: pthread_t is non-optional
            var thread: pthread_t = 0

            let result = pthread_create(
                &thread,
                nil,
                { ctx in
                    guard let ctx else { return nil }
                    let bodyPtr = ctx.assumingMemoryBound(to: (@Sendable () -> Void).self)
                    let work = bodyPtr.move()
                    bodyPtr.deallocate()
                    work()
                    return nil
                },
                context
            )

            guard result == 0 else {
                context.deinitialize(count: 1)
                context.deallocate()
                throw .create(.posix(result))
            }

            return Handle(rawValue: thread)
        #endif
    }
}
