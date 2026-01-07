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

extension Kernel.File.Clone.Capability {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Clone.Capability.Test.Unit {
    @Test("reflink case exists")
    func reflinkCase() {
        let capability = Kernel.File.Clone.Capability.reflink
        if case .reflink = capability {
            // Expected
        } else {
            Issue.record("Expected .reflink case")
        }
    }

    @Test("none case exists")
    func noneCase() {
        let capability = Kernel.File.Clone.Capability.none
        if case .none = capability {
            // Expected
        } else {
            Issue.record("Expected .none case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Clone.Capability.Test.Unit {
    @Test("Capability is Sendable")
    func isSendable() {
        let capability: any Sendable = Kernel.File.Clone.Capability.reflink
        #expect(capability is Kernel.File.Clone.Capability)
    }

    @Test("Capability is Equatable")
    func isEquatable() {
        let a = Kernel.File.Clone.Capability.reflink
        let b = Kernel.File.Clone.Capability.reflink
        let c = Kernel.File.Clone.Capability.none
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Clone.Capability.Test.EdgeCase {
    @Test("reflink and none are distinct")
    func casesDistinct() {
        let reflink = Kernel.File.Clone.Capability.reflink
        let none = Kernel.File.Clone.Capability.none
        #expect(reflink != none)
    }

    @Test("all cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.File.Clone.Capability] = [
            .reflink,
            .none,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}
