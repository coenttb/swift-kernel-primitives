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

import StandardsTestSupport
import Testing

@testable import Kernel_Primitives

extension Kernel.Lock.Acquire {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Lock.Acquire.Test.Unit {
    @Test("try case exists")
    func tryCase() {
        let acquire = Kernel.Lock.Acquire.try
        if case .try = acquire {
            // Expected
        } else {
            Issue.record("Expected .try case")
        }
    }

    @Test("wait case exists")
    func waitCase() {
        let acquire = Kernel.Lock.Acquire.wait
        if case .wait = acquire {
            // Expected
        } else {
            Issue.record("Expected .wait case")
        }
    }

    @Test("deadline case exists")
    func deadlineCase() {
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        let acquire = Kernel.Lock.Acquire.deadline(deadline)
        if case .deadline(let d) = acquire {
            #expect(d == deadline)
        } else {
            Issue.record("Expected .deadline case")
        }
    }

    @Test("timeout factory creates deadline")
    func timeoutFactory() {
        let before = ContinuousClock.now
        let acquire = Kernel.Lock.Acquire.timeout(.seconds(1))
        let after = ContinuousClock.now

        if case .deadline(let deadline) = acquire {
            // Deadline should be approximately 1 second from now
            let expectedMin = before.advanced(by: .seconds(1))
            let expectedMax = after.advanced(by: .seconds(1))
            #expect(deadline >= expectedMin)
            #expect(deadline <= expectedMax)
        } else {
            Issue.record("Expected .deadline case from timeout")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Lock.Acquire.Test.Unit {
    @Test("Acquire is Sendable")
    func isSendable() {
        let acquire: any Sendable = Kernel.Lock.Acquire.wait
        #expect(acquire is Kernel.Lock.Acquire)
    }

    @Test("Acquire is Equatable")
    func isEquatable() {
        let a = Kernel.Lock.Acquire.wait
        let b = Kernel.Lock.Acquire.wait
        let c = Kernel.Lock.Acquire.try
        #expect(a == b)
        #expect(a != c)
    }

    @Test("try and wait are distinct")
    func tryWaitDistinct() {
        let tryAcquire = Kernel.Lock.Acquire.try
        let waitAcquire = Kernel.Lock.Acquire.wait
        #expect(tryAcquire != waitAcquire)
    }

    @Test("deadlines with same instant are equal")
    func deadlineEquality() {
        let instant = ContinuousClock.now.advanced(by: .seconds(10))
        let a = Kernel.Lock.Acquire.deadline(instant)
        let b = Kernel.Lock.Acquire.deadline(instant)
        #expect(a == b)
    }

    @Test("deadlines with different instants are distinct")
    func deadlineDistinct() {
        let a = Kernel.Lock.Acquire.deadline(ContinuousClock.now.advanced(by: .seconds(1)))
        let b = Kernel.Lock.Acquire.deadline(ContinuousClock.now.advanced(by: .seconds(2)))
        #expect(a != b)
    }
}

// MARK: - Edge Cases

extension Kernel.Lock.Acquire.Test.EdgeCase {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.Lock.Acquire] = [
            .try,
            .wait,
            .deadline(ContinuousClock.now),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("timeout with zero duration")
    func zeroTimeout() {
        let acquire = Kernel.Lock.Acquire.timeout(.zero)
        if case .deadline = acquire {
            // Expected - creates a deadline that is now
        } else {
            Issue.record("Expected .deadline case")
        }
    }

    @Test("timeout with large duration")
    func largeTimeout() {
        let acquire = Kernel.Lock.Acquire.timeout(.seconds(3600))
        if case .deadline(let deadline) = acquire {
            let now = ContinuousClock.now
            let oneHourFromNow = now.advanced(by: .seconds(3600))
            // Deadline should be approximately 1 hour from now
            #expect(deadline >= now)
            #expect(deadline <= oneHourFromNow.advanced(by: .seconds(1)))
        } else {
            Issue.record("Expected .deadline case")
        }
    }

    @Test("deadline in the past")
    func pastDeadline() {
        let pastInstant = ContinuousClock.now.advanced(by: .seconds(-10))
        let acquire = Kernel.Lock.Acquire.deadline(pastInstant)
        if case .deadline(let deadline) = acquire {
            #expect(deadline == pastInstant)
        } else {
            Issue.record("Expected .deadline case")
        }
    }
}
