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

extension Kernel.File.Direct.Mode {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Mode.Test.Unit {
    @Test("direct case exists")
    func directCase() {
        let mode = Kernel.File.Direct.Mode.direct
        if case .direct = mode {
            // Expected
        } else {
            Issue.record("Expected .direct case")
        }
    }

    @Test("uncached case exists")
    func uncachedCase() {
        let mode = Kernel.File.Direct.Mode.uncached
        if case .uncached = mode {
            // Expected
        } else {
            Issue.record("Expected .uncached case")
        }
    }

    @Test("buffered case exists")
    func bufferedCase() {
        let mode = Kernel.File.Direct.Mode.buffered
        if case .buffered = mode {
            // Expected
        } else {
            Issue.record("Expected .buffered case")
        }
    }

    @Test("auto case exists")
    func autoCase() {
        let mode = Kernel.File.Direct.Mode.auto(policy: .fallbackToBuffered)
        if case .auto = mode {
            // Expected
        } else {
            Issue.record("Expected .auto case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Mode.Test.Unit {
    @Test("Mode is Sendable")
    func isSendable() {
        let mode: any Sendable = Kernel.File.Direct.Mode.buffered
        #expect(mode is Kernel.File.Direct.Mode)
    }

    @Test("Mode is Equatable")
    func isEquatable() {
        let a = Kernel.File.Direct.Mode.buffered
        let b = Kernel.File.Direct.Mode.buffered
        let c = Kernel.File.Direct.Mode.direct
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Nested Types

extension Kernel.File.Direct.Mode.Test.Unit {
    @Test("Mode.Policy type exists")
    func policyTypeExists() {
        let _: Kernel.File.Direct.Mode.Policy.Type = Kernel.File.Direct.Mode.Policy.self
    }

    @Test("Mode.Resolved type exists")
    func resolvedTypeExists() {
        let _: Kernel.File.Direct.Mode.Resolved.Type = Kernel.File.Direct.Mode.Resolved.self
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Mode.Test.EdgeCase {
    @Test("all simple cases are distinct")
    func simpleCasesDistinct() {
        let cases: [Kernel.File.Direct.Mode] = [
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

    @Test("auto with different policies are distinct")
    func autoPoliciesDistinct() {
        let fallback = Kernel.File.Direct.Mode.auto(policy: .fallbackToBuffered)
        let error = Kernel.File.Direct.Mode.auto(policy: .errorOnViolation)
        #expect(fallback != error)
    }
}
