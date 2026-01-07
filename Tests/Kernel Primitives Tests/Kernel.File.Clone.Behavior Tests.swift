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

extension Kernel.File.Clone.Behavior {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Clone.Behavior.Test.Unit {
    @Test("reflinkOrFail case exists")
    func reflinkOrFailCase() {
        let behavior = Kernel.File.Clone.Behavior.reflinkOrFail
        if case .reflinkOrFail = behavior {
            // Expected
        } else {
            Issue.record("Expected .reflinkOrFail case")
        }
    }

    @Test("reflinkOrCopy case exists")
    func reflinkOrCopyCase() {
        let behavior = Kernel.File.Clone.Behavior.reflinkOrCopy
        if case .reflinkOrCopy = behavior {
            // Expected
        } else {
            Issue.record("Expected .reflinkOrCopy case")
        }
    }

    @Test("copyOnly case exists")
    func copyOnlyCase() {
        let behavior = Kernel.File.Clone.Behavior.copyOnly
        if case .copyOnly = behavior {
            // Expected
        } else {
            Issue.record("Expected .copyOnly case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Clone.Behavior.Test.Unit {
    @Test("Behavior is Sendable")
    func isSendable() {
        let behavior: any Sendable = Kernel.File.Clone.Behavior.reflinkOrCopy
        #expect(behavior is Kernel.File.Clone.Behavior)
    }

    @Test("Behavior is Equatable")
    func isEquatable() {
        let a = Kernel.File.Clone.Behavior.reflinkOrCopy
        let b = Kernel.File.Clone.Behavior.reflinkOrCopy
        let c = Kernel.File.Clone.Behavior.copyOnly
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Clone.Behavior.Test.EdgeCase {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.File.Clone.Behavior] = [
            .reflinkOrFail,
            .reflinkOrCopy,
            .copyOnly,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}
