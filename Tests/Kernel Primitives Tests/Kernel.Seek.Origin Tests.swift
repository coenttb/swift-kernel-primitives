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

extension Kernel.Seek.Origin {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Seek.Origin.Test.Unit {
    @Test("start case exists")
    func startCase() {
        let origin = Kernel.Seek.Origin.start
        if case .start = origin {
            // Expected
        } else {
            Issue.record("Expected .start case")
        }
    }

    @Test("current case exists")
    func currentCase() {
        let origin = Kernel.Seek.Origin.current
        if case .current = origin {
            // Expected
        } else {
            Issue.record("Expected .current case")
        }
    }

    @Test("end case exists")
    func endCase() {
        let origin = Kernel.Seek.Origin.end
        if case .end = origin {
            // Expected
        } else {
            Issue.record("Expected .end case")
        }
    }
}

// MARK: - Conformances

extension Kernel.Seek.Origin.Test.Unit {
    @Test("Origin is Sendable")
    func isSendable() {
        let origin: any Sendable = Kernel.Seek.Origin.start
        #expect(origin is Kernel.Seek.Origin)
    }
}

// MARK: - Edge Cases

extension Kernel.Seek.Origin.Test.EdgeCase {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let start = Kernel.Seek.Origin.start
        let current = Kernel.Seek.Origin.current
        let end = Kernel.Seek.Origin.end

        // Pattern matching confirms distinctness
        switch start {
        case .start:
            break  // expected
        case .current, .end:
            Issue.record("start should not match current or end")
        }

        switch current {
        case .current:
            break  // expected
        case .start, .end:
            Issue.record("current should not match start or end")
        }

        switch end {
        case .end:
            break  // expected
        case .start, .current:
            Issue.record("end should not match start or current")
        }
    }
}

// MARK: - Usage Patterns

extension Kernel.Seek.Origin.Test.Unit {
    @Test("Origin can be used in switch")
    func switchUsage() {
        func describe(_ origin: Kernel.Seek.Origin) -> String {
            switch origin {
            case .start: return "beginning"
            case .current: return "current position"
            case .end: return "end"
            }
        }

        #expect(describe(.start) == "beginning")
        #expect(describe(.current) == "current position")
        #expect(describe(.end) == "end")
    }
}
