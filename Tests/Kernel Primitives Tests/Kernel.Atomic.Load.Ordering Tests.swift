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

extension Kernel.Atomic.Load.Ordering {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Atomic.Load.Ordering.Test.Unit {
    @Test("relaxed case exists")
    func relaxedCase() {
        let ordering = Kernel.Atomic.Load.Ordering.relaxed
        if case .relaxed = ordering {
            // Expected
        } else {
            Issue.record("Expected .relaxed case")
        }
    }

    @Test("acquiring case exists")
    func acquiringCase() {
        let ordering = Kernel.Atomic.Load.Ordering.acquiring
        if case .acquiring = ordering {
            // Expected
        } else {
            Issue.record("Expected .acquiring case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Atomic.Load.Ordering.Test.Unit {
    @Test("Ordering is Sendable")
    func isSendable() {
        let ordering: any Sendable = Kernel.Atomic.Load.Ordering.relaxed
        #expect(ordering is Kernel.Atomic.Load.Ordering)
    }
}

// MARK: - Usage Tests

extension Kernel.Atomic.Load.Ordering.Test.Unit {
    @Test("relaxed can be used with Atomic.load")
    func relaxedUsage() {
        var value: Int = 42
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == 42)
    }

    @Test("acquiring can be used with Atomic.load")
    func acquiringUsage() {
        var value: Int = 42
        let loaded = Kernel.Atomic.load(&value, ordering: .acquiring)
        #expect(loaded == 42)
    }
}

// MARK: - Edge Cases

extension Kernel.Atomic.Load.Ordering.Test.EdgeCase {
    @Test("relaxed and acquiring are distinct")
    func casesDistinct() {
        let relaxed = Kernel.Atomic.Load.Ordering.relaxed
        let acquiring = Kernel.Atomic.Load.Ordering.acquiring

        if case .relaxed = relaxed, case .acquiring = acquiring {
            // Cases are distinct as expected
        } else {
            Issue.record("Cases should be distinct")
        }
    }

    @Test("all orderings produce same result in single-threaded context")
    func orderingsEquivalentSingleThread() {
        var value: Int = 42

        let relaxedValue = Kernel.Atomic.load(&value, ordering: .relaxed)
        let acquiringValue = Kernel.Atomic.load(&value, ordering: .acquiring)

        #expect(relaxedValue == acquiringValue)
    }
}
