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

import Kernel_Primitives_Test_Support
import StandardsTestSupport
import Testing

@testable import Kernel_Primitives

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension Kernel.Thread.Mutex {
    #TestSuites
}

// MARK: - API Unit Tests

extension Kernel.Thread.Mutex.Test.Unit {
    @Test("init creates valid mutex")
    func initCreatesValidMutex() {
        let mutex = Kernel.Thread.Mutex()
        _ = mutex
    }

    @Test("lock and unlock complete successfully")
    func lockAndUnlockSucceed() {
        let mutex = Kernel.Thread.Mutex()
        mutex.lock()
        mutex.unlock()
    }

    @Test("tryLock returns true when available")
    func tryLockReturnsTrueWhenAvailable() {
        let mutex = Kernel.Thread.Mutex()
        let acquired = mutex.tryLock()
        #expect(acquired == true)
        mutex.unlock()
    }

    @Test("tryLock and unlock cycle works repeatedly")
    func tryLockUnlockCycle() {
        let mutex = Kernel.Thread.Mutex()
        let iterations = 100

        for _ in 0..<iterations {
            let acquired = mutex.tryLock()
            #expect(acquired == true)
            mutex.unlock()
        }
    }

    @Test("withLock executes body")
    func withLockExecutesBody() {
        let mutex = Kernel.Thread.Mutex()
        var executed = false

        mutex.withLock {
            executed = true
        }

        #expect(executed == true)
    }

    @Test("withLock returns value from body")
    func withLockReturnsValue() {
        let mutex = Kernel.Thread.Mutex()

        let result = mutex.withLock {
            return 42
        }

        #expect(result == 42)
    }

    @Test("withLock releases mutex after body")
    func withLockReleasesMutex() {
        let mutex = Kernel.Thread.Mutex()

        mutex.withLock {}

        let acquired = mutex.tryLock()
        #expect(acquired == true)
        mutex.unlock()
    }

    @Test("withLock releases mutex on throw")
    func withLockReleasesOnThrow() throws {
        let mutex = Kernel.Thread.Mutex()

        struct TestError: Error {}

        do {
            try mutex.withLock {
                throw TestError()
            }
        } catch is TestError {}

        let acquired = mutex.tryLock()
        #expect(acquired == true)
        mutex.unlock()
    }

    @Test("multiple mutexes are independent")
    func multipleMutexesIndependent() {
        let mutex1 = Kernel.Thread.Mutex()
        let mutex2 = Kernel.Thread.Mutex()

        mutex1.lock()
        let acquired = mutex2.tryLock()
        #expect(acquired == true)
        mutex2.unlock()
        mutex1.unlock()
    }

    @Test("nested withLock on different mutexes")
    func nestedWithLockDifferentMutexes() {
        let mutex1 = Kernel.Thread.Mutex()
        let mutex2 = Kernel.Thread.Mutex()
        var innerExecuted = false

        mutex1.withLock {
            mutex2.withLock {
                innerExecuted = true
            }
        }

        #expect(innerExecuted == true)
    }
}

// MARK: - Mutual Exclusion Tests (require threading)
//
// These tests use KernelThreadTest.Harness to coordinate between threads
// without data races or cross-thread mutex unlock.

// NOTE: These tests use Darwin-specific pthread API.
// Linux pthread API differs (non-optional pthread_t, different closure signature).
// TODO: Add Linux-compatible threading tests to swift-linux package.
#if canImport(Darwin)

    extension Kernel.Thread.Mutex.Test.Unit {
        @Test("tryLock returns false when held by another thread")
        func tryLockReturnsFalseWhenHeld() throws {
            let mutex = Kernel.Thread.Mutex()

            struct State {
                var workerAttempting = false
                var tryLockResult: Bool? = nil
                var workerDone = false
            }
            let harness = KernelThreadTest.Harness(State())

            // Context to pass both mutex and harness through the C function pointer
            final class Context: @unchecked Sendable {
                let mutex: Kernel.Thread.Mutex
                let harness: KernelThreadTest.Harness<State>

                init(mutex: Kernel.Thread.Mutex, harness: KernelThreadTest.Harness<State>) {
                    self.mutex = mutex
                    self.harness = harness
                }
            }
            let context = Context(mutex: mutex, harness: harness)

            // Main thread holds the mutex
            mutex.lock()
            defer { mutex.unlock() }

            var thread: pthread_t? = nil
            let contextPtr = Unmanaged.passRetained(context).toOpaque()

            let rc = pthread_create(
                &thread,
                nil,
                { raw -> UnsafeMutableRawPointer? in
                    let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                    ctx.harness.update { $0.workerAttempting = true }

                    // This should fail because main thread holds the mutex
                    let ok = ctx.mutex.tryLock()
                    if ok {
                        ctx.mutex.unlock()
                    }

                    ctx.harness.update {
                        $0.tryLockResult = ok
                        $0.workerDone = true
                    }
                    return nil
                },
                contextPtr
            )

            #expect(rc == 0, "pthread_create should succeed")

            // Wait for worker to attempt tryLock
            try harness.wait(until: { $0.workerAttempting })
            try harness.wait(until: { $0.workerDone })

            let result = harness.withLocked { $0.tryLockResult }
            #expect(result == false, "tryLock must return false when mutex is held by another thread")

            if let t = thread {
                pthread_join(t, nil)
            }
        }

        @Test("lock blocks until mutex is available")
        func lockBlocksUntilAvailable() throws {
            let mutex = Kernel.Thread.Mutex()

            struct State {
                var workerAttempting = false
                var workerAcquired = false
            }
            let harness = KernelThreadTest.Harness(State())

            final class Context: @unchecked Sendable {
                let mutex: Kernel.Thread.Mutex
                let harness: KernelThreadTest.Harness<State>

                init(mutex: Kernel.Thread.Mutex, harness: KernelThreadTest.Harness<State>) {
                    self.mutex = mutex
                    self.harness = harness
                }
            }
            let context = Context(mutex: mutex, harness: harness)

            // Main thread holds the mutex
            mutex.lock()

            var thread: pthread_t? = nil
            let contextPtr = Unmanaged.passRetained(context).toOpaque()

            let rc = pthread_create(
                &thread,
                nil,
                { raw -> UnsafeMutableRawPointer? in
                    let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                    ctx.harness.update { $0.workerAttempting = true }

                    // This should block until main thread unlocks
                    ctx.mutex.lock()
                    ctx.harness.update { $0.workerAcquired = true }
                    ctx.mutex.unlock()

                    return nil
                },
                contextPtr
            )

            #expect(rc == 0, "pthread_create should succeed")

            // Wait for worker to start attempting
            try harness.wait(until: { $0.workerAttempting })

            // Worker should NOT have acquired yet (it should be blocked)
            #expect(
                harness.withLocked { $0.workerAcquired } == false,
                "Worker should be blocked waiting for mutex"
            )

            // Release the mutex
            mutex.unlock()

            // Now worker should acquire
            try harness.wait(until: { $0.workerAcquired })

            if let t = thread {
                pthread_join(t, nil)
            }
        }

        @Test("mutex protects shared counter from data races")
        func mutexProtectsSharedCounter() throws {
            let mutex = Kernel.Thread.Mutex()

            struct State {
                var counter: Int = 0
                var threadsCompleted: Int = 0
            }
            let harness = KernelThreadTest.Harness(State())

            final class Context: @unchecked Sendable {
                let mutex: Kernel.Thread.Mutex
                let harness: KernelThreadTest.Harness<State>
                let iterations: Int

                init(mutex: Kernel.Thread.Mutex, harness: KernelThreadTest.Harness<State>, iterations: Int) {
                    self.mutex = mutex
                    self.harness = harness
                    self.iterations = iterations
                }
            }

            let iterations = 10_000
            let threadCount = 4
            let context = Context(mutex: mutex, harness: harness, iterations: iterations)

            var threads: [pthread_t?] = Array(repeating: nil, count: threadCount)

            for i in 0..<threadCount {
                let contextPtr = Unmanaged.passRetained(context).toOpaque()
                let rc = pthread_create(
                    &threads[i],
                    nil,
                    { raw -> UnsafeMutableRawPointer? in
                        let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                        for _ in 0..<ctx.iterations {
                            ctx.mutex.withLock {
                                ctx.harness.withLocked { $0.counter += 1 }
                            }
                        }

                        ctx.harness.update { $0.threadsCompleted += 1 }
                        return nil
                    },
                    contextPtr
                )

                #expect(rc == 0, "pthread_create should succeed for thread \(i)")
            }

            // Wait for all threads to complete
            try harness.wait(until: { $0.threadsCompleted >= threadCount })

            for i in 0..<threadCount {
                if let t = threads[i] {
                    pthread_join(t, nil)
                }
            }

            let finalCount = harness.withLocked { $0.counter }
            #expect(
                finalCount == iterations * threadCount,
                "Counter should be exactly \(iterations * threadCount), got \(finalCount)"
            )
        }
    }

#endif
