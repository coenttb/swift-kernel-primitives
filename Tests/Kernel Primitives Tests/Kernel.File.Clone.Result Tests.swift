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

extension Kernel.File.Clone.Result {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Clone.Result.Test.Unit {
    @Test("reflinked case exists")
    func reflinkedCase() {
        let result = Kernel.File.Clone.Result.reflinked
        if case .reflinked = result {
            // Expected
        } else {
            Issue.record("Expected .reflinked case")
        }
    }

    @Test("copied case exists")
    func copiedCase() {
        let result = Kernel.File.Clone.Result.copied
        if case .copied = result {
            // Expected
        } else {
            Issue.record("Expected .copied case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Clone.Result.Test.Unit {
    @Test("Result is Sendable")
    func isSendable() {
        let result: any Sendable = Kernel.File.Clone.Result.reflinked
        #expect(result is Kernel.File.Clone.Result)
    }

    @Test("Result is Equatable")
    func isEquatable() {
        let a = Kernel.File.Clone.Result.reflinked
        let b = Kernel.File.Clone.Result.reflinked
        let c = Kernel.File.Clone.Result.copied
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Clone.Result.Test.EdgeCase {
    @Test("reflinked and copied are distinct")
    func casesDistinct() {
        let reflinked = Kernel.File.Clone.Result.reflinked
        let copied = Kernel.File.Clone.Result.copied
        #expect(reflinked != copied)
    }

    @Test("all cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.File.Clone.Result] = [
            .reflinked,
            .copied,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}
