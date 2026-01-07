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

import Kernel_Primitives_Test_Support
import StandardsTestSupport
import Testing

@testable import Kernel_Primitives

extension Kernel.Lock {
    #TestSuites
}

// MARK: - Range Unit Tests

extension Kernel.Lock.Test.Unit {
    @Test("Range.file is equatable")
    func rangeFileEquatable() {
        let r1 = Kernel.Lock.Range.file
        let r2 = Kernel.Lock.Range.file
        #expect(r1 == r2)
    }

    @Test("Range.bytes is equatable")
    func rangeBytesEquatable() {
        let r1 = Kernel.Lock.Range.bytes(start: Kernel.File.Offset(10), end: Kernel.File.Offset(110))
        let r2 = Kernel.Lock.Range.bytes(start: Kernel.File.Offset(10), end: Kernel.File.Offset(110))
        let r3 = Kernel.Lock.Range.bytes(start: Kernel.File.Offset(20), end: Kernel.File.Offset(120))

        #expect(r1 == r2)
        #expect(r1 != r3)
    }

    @Test("Range.file and Range.bytes are not equal")
    func rangeFileVsBytes() {
        let file = Kernel.Lock.Range.file
        let bytes = Kernel.Lock.Range.bytes(start: .zero, end: .zero)

        #expect(file != bytes)
    }

    @Test("Range.bytes with length convenience")
    func rangeBytesWithLength() {
        let range = Kernel.Lock.Range.bytes(start: Kernel.File.Offset(100), length: Kernel.File.Size(100))
        #expect(range == .bytes(start: Kernel.File.Offset(100), end: Kernel.File.Offset(200)))
    }
}

// MARK: - Kind Unit Tests

extension Kernel.Lock.Test.Unit {
    @Test("Kind.shared and Kind.exclusive")
    func kindValues() {
        let shared = Kernel.Lock.Kind.shared
        let exclusive = Kernel.Lock.Kind.exclusive

        #expect(shared != exclusive)
        #expect(shared == .shared)
        #expect(exclusive == .exclusive)
    }
}

// MARK: - Acquire Unit Tests

extension Kernel.Lock.Test.Unit {
    @Test("Acquire.try case")
    func acquireTry() {
        let acquire = Kernel.Lock.Acquire.try
        #expect(acquire == .try)
    }

    @Test("Acquire.wait case")
    func acquireWait() {
        let acquire = Kernel.Lock.Acquire.wait
        #expect(acquire == .wait)
    }

    @Test("Acquire.timeout creates deadline from duration")
    func acquireTimeout() {
        let before = ContinuousClock.now
        let acquire = Kernel.Lock.Acquire.timeout(.seconds(1))

        if case .deadline(let deadline) = acquire {
            // Deadline should be approximately now + 1 second
            // Allow small tolerance for clock sampling
            let expectedMin = before.advanced(by: .milliseconds(999))
            let expectedMax = before.advanced(by: .milliseconds(1100))
            #expect(deadline >= expectedMin, "Deadline should be at least 1 second from before")
            #expect(deadline <= expectedMax, "Deadline should be close to 1 second from before")
        } else {
            Issue.record("Expected .deadline case")
        }
    }

    @Test("Acquire is equatable")
    func acquireEquatable() {
        #expect(Kernel.Lock.Acquire.try == .try)
        #expect(Kernel.Lock.Acquire.wait == .wait)
        #expect(Kernel.Lock.Acquire.try != .wait)
    }
}

// MARK: - Hashable Tests

extension Kernel.Lock.Test.Unit {
    @Test("Range is hashable")
    func rangeHashable() {
        var set = Set<Kernel.Lock.Range>()
        set.insert(.file)
        set.insert(.bytes(start: Kernel.File.Offset(10), end: Kernel.File.Offset(30)))
        set.insert(.bytes(start: Kernel.File.Offset(10), end: Kernel.File.Offset(30)))  // Duplicate

        #expect(set.count == 2)
    }

    @Test("Kind is hashable")
    func kindHashable() {
        var set = Set<Kernel.Lock.Kind>()
        set.insert(.shared)
        set.insert(.exclusive)
        set.insert(.shared)  // Duplicate

        #expect(set.count == 2)
    }
}

// MARK: - File Locking API Tests
//
// NOTE: These tests verify API correctness (no crashes, correct return values).
// POSIX fcntl locks are per-process, not per-thread, so same-process tests
// cannot verify contention semantics. Cross-process contention is tested in
// Kernel Tests/Kernel.Lock.Integration Tests.swift using the _Lock Test Process helper.

#if !os(Windows)

    extension Kernel.Lock.Test.Unit {
        @Test("lock and unlock on file succeeds")
        func lockAndUnlockSucceeds() throws {
            try KernelIOTest.withTempFile(prefix: "lock-test") { _, fd in
                try Kernel.Lock.lock(fd, range: .file, kind: .exclusive)
                try Kernel.Lock.unlock(fd, range: .file)
            }
        }

        @Test("tryLock returns true on uncontested file")
        func tryLockReturnsTrueUncontested() throws {
            try KernelIOTest.withTempFile(prefix: "lock-test") { _, fd in
                let acquired = try Kernel.Lock.tryLock(fd, range: .file, kind: .exclusive)
                #expect(acquired == true)
                try Kernel.Lock.unlock(fd, range: .file)
            }
        }

        @Test("multiple descriptors can lock same file within process")
        func multipleDescriptorsSameProcess() throws {
            // NOTE: This demonstrates POSIX behavior where same-process locks don't contend.
            // It is NOT testing that "shared allows multiple" in a meaningful way.
            // Cross-process contention is tested in the Integration Tests.
            try KernelIOTest.withTempFile(prefix: "lock-test") { path, fd1 in
                let fd2 = try Kernel.File.Open.open(path: path, mode: [.read, .write], options: [], permissions: .privateFile)
                defer { try? Kernel.Close.close(fd2) }

                try Kernel.Lock.lock(fd1, range: .file, kind: .shared)
                let acquired = try Kernel.Lock.tryLock(fd2, range: .file, kind: .shared)
                #expect(acquired == true)

                try Kernel.Lock.unlock(fd1, range: .file)
                try Kernel.Lock.unlock(fd2, range: .file)
            }
        }

        @Test("byte range locks on non-overlapping regions")
        func nonOverlappingByteRanges() throws {
            try KernelIOTest.withTempFile(prefix: "lock-test") { _, fd in
                let range1 = Kernel.Lock.Range.bytes(start: Kernel.File.Offset(0), end: Kernel.File.Offset(100))
                let range2 = Kernel.Lock.Range.bytes(start: Kernel.File.Offset(200), end: Kernel.File.Offset(300))

                try Kernel.Lock.lock(fd, range: range1, kind: .exclusive)
                let acquired = try Kernel.Lock.tryLock(fd, range: range2, kind: .exclusive)
                #expect(acquired == true)

                try Kernel.Lock.unlock(fd, range: range1)
                try Kernel.Lock.unlock(fd, range: range2)
            }
        }

        @Test("unlock on non-locked region is no-op on POSIX")
        func unlockNonLockedRegion() throws {
            // POSIX: unlocking a region not locked by the process is a no-op, not an error
            try KernelIOTest.withTempFile(prefix: "lock-test") { _, fd in
                // Should not throw
                try Kernel.Lock.unlock(fd, range: .file)
            }
        }
    }

    // MARK: - Token Tests

    extension Kernel.Lock.Test.Unit {
        @Test("Token acquires and releases lock")
        func tokenAcquiresAndReleases() throws {
            try KernelIOTest.withTempFile(prefix: "lock-token") { _, fd in
                var token = try Kernel.Lock.Token(
                    descriptor: fd,
                    range: .file,
                    kind: .exclusive,
                    acquire: .wait
                )

                try token.release()

                // Should be able to acquire again after release
                let acquired = try Kernel.Lock.tryLock(fd, range: .file, kind: .exclusive)
                #expect(acquired == true)
                try Kernel.Lock.unlock(fd, range: .file)
            }
        }

        @Test("Token with try acquire succeeds when uncontested")
        func tokenTryAcquireSucceeds() throws {
            try KernelIOTest.withTempFile(prefix: "lock-token") { _, fd in
                var token = try Kernel.Lock.Token(
                    descriptor: fd,
                    range: .file,
                    kind: .exclusive,
                    acquire: .try
                )

                try token.release()
            }
        }

        @Test("Token release is idempotent")
        func tokenReleaseIdempotent() throws {
            try KernelIOTest.withTempFile(prefix: "lock-token") { _, fd in
                var token = try Kernel.Lock.Token(
                    descriptor: fd,
                    range: .file,
                    kind: .exclusive
                )

                try token.release()
                try token.release()  // Should be no-op
            }
        }

        @Test("Token with byte range lock")
        func tokenByteRangeLock() throws {
            try KernelIOTest.withTempFile(prefix: "lock-token") { _, fd in
                let range = Kernel.Lock.Range.bytes(start: Kernel.File.Offset(0), end: Kernel.File.Offset(512))

                var token = try Kernel.Lock.Token(
                    descriptor: fd,
                    range: range,
                    kind: .shared
                )

                try token.release()
            }
        }
    }

    // MARK: - withExclusive/withShared Tests

    extension Kernel.Lock.Test.Unit {
        @Test("withExclusive executes body and releases lock")
        func withExclusiveExecutesBody() throws {
            try KernelIOTest.withTempFile(prefix: "lock-with") { _, fd in
                var executed = false
                try Kernel.Lock.withExclusive(fd) {
                    executed = true
                }

                #expect(executed == true)

                // Lock should be released
                let acquired = try Kernel.Lock.tryLock(fd, range: .file, kind: .exclusive)
                #expect(acquired == true)
                try Kernel.Lock.unlock(fd, range: .file)
            }
        }

        @Test("withExclusive returns value from body")
        func withExclusiveReturnsValue() throws {
            try KernelIOTest.withTempFile(prefix: "lock-with") { _, fd in
                let result = try Kernel.Lock.withExclusive(fd) {
                    return 42
                }

                #expect(result == 42)
            }
        }

        @Test("withShared executes body and releases lock")
        func withSharedExecutesBody() throws {
            try KernelIOTest.withTempFile(prefix: "lock-with") { _, fd in
                var executed = false
                try Kernel.Lock.withShared(fd) {
                    executed = true
                }

                #expect(executed == true)
            }
        }

        @Test("withExclusive releases lock on throw")
        func withExclusiveReleasesOnThrow() throws {
            try KernelIOTest.withTempFile(prefix: "lock-with") { _, fd in
                struct TestError: Error {}

                do {
                    try Kernel.Lock.withExclusive(fd) {
                        throw TestError()
                    }
                } catch is TestError {}

                // Lock should be released
                let acquired = try Kernel.Lock.tryLock(fd, range: .file, kind: .exclusive)
                #expect(acquired == true)
                try Kernel.Lock.unlock(fd, range: .file)
            }
        }
    }

#endif
