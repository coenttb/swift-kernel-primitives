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

extension Kernel.File.Direct.Mode.Resolved {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Mode.Resolved.Test.Unit {
    @Test("direct case exists")
    func directCase() {
        let resolved = Kernel.File.Direct.Mode.Resolved.direct
        if case .direct = resolved {
            // Expected
        } else {
            Issue.record("Expected .direct case")
        }
    }

    @Test("uncached case exists")
    func uncachedCase() {
        let resolved = Kernel.File.Direct.Mode.Resolved.uncached
        if case .uncached = resolved {
            // Expected
        } else {
            Issue.record("Expected .uncached case")
        }
    }

    @Test("buffered case exists")
    func bufferedCase() {
        let resolved = Kernel.File.Direct.Mode.Resolved.buffered
        if case .buffered = resolved {
            // Expected
        } else {
            Issue.record("Expected .buffered case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Mode.Resolved.Test.Unit {
    @Test("Resolved is Sendable")
    func isSendable() {
        let resolved: any Sendable = Kernel.File.Direct.Mode.Resolved.buffered
        #expect(resolved is Kernel.File.Direct.Mode.Resolved)
    }

    @Test("Resolved is Equatable")
    func isEquatable() {
        let a = Kernel.File.Direct.Mode.Resolved.buffered
        let b = Kernel.File.Direct.Mode.Resolved.buffered
        let c = Kernel.File.Direct.Mode.Resolved.direct
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Mode.Resolved.Test.EdgeCase {
    @Test("all resolved modes are distinct")
    func allResolvedDistinct() {
        let cases: [Kernel.File.Direct.Mode.Resolved] = [
            .direct,
            .uncached,
            .buffered,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}
