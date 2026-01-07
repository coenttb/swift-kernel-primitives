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

extension Kernel.Atomic.Store.Ordering {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Atomic.Store.Ordering.Test.Unit {
    @Test("relaxed case exists")
    func relaxedCase() {
        let ordering = Kernel.Atomic.Store.Ordering.relaxed
        if case .relaxed = ordering {
            // Expected
        } else {
            Issue.record("Expected .relaxed case")
        }
    }

    @Test("releasing case exists")
    func releasingCase() {
        let ordering = Kernel.Atomic.Store.Ordering.releasing
        if case .releasing = ordering {
            // Expected
        } else {
            Issue.record("Expected .releasing case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Atomic.Store.Ordering.Test.Unit {
    @Test("Ordering is Sendable")
    func isSendable() {
        let ordering: any Sendable = Kernel.Atomic.Store.Ordering.relaxed
        #expect(ordering is Kernel.Atomic.Store.Ordering)
    }
}

// MARK: - Usage Tests

extension Kernel.Atomic.Store.Ordering.Test.Unit {
    @Test("relaxed can be used with Atomic.store")
    func relaxedUsage() {
        var value: Int = 0
        Kernel.Atomic.store(&value, 42, ordering: .relaxed)
        #expect(value == 42)
    }

    @Test("releasing can be used with Atomic.store")
    func releasingUsage() {
        var value: Int = 0
        Kernel.Atomic.store(&value, 42, ordering: .releasing)
        #expect(value == 42)
    }
}

// MARK: - Edge Cases

extension Kernel.Atomic.Store.Ordering.Test.EdgeCase {
    @Test("relaxed and releasing are distinct")
    func casesDistinct() {
        let relaxed = Kernel.Atomic.Store.Ordering.relaxed
        let releasing = Kernel.Atomic.Store.Ordering.releasing

        if case .relaxed = relaxed, case .releasing = releasing {
            // Cases are distinct as expected
        } else {
            Issue.record("Cases should be distinct")
        }
    }

    @Test("all orderings produce same result in single-threaded context")
    func orderingsEquivalentSingleThread() {
        var value1: Int = 0
        var value2: Int = 0

        Kernel.Atomic.store(&value1, 42, ordering: .relaxed)
        Kernel.Atomic.store(&value2, 42, ordering: .releasing)

        #expect(value1 == value2)
    }
}
