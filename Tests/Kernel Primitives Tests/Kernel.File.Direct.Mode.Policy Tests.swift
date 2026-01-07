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

extension Kernel.File.Direct.Mode.Policy {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Mode.Policy.Test.Unit {
    @Test("fallbackToBuffered case exists")
    func fallbackToBufferedCase() {
        let policy = Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        if case .fallbackToBuffered = policy {
            // Expected
        } else {
            Issue.record("Expected .fallbackToBuffered case")
        }
    }

    @Test("errorOnViolation case exists")
    func errorOnViolationCase() {
        let policy = Kernel.File.Direct.Mode.Policy.errorOnViolation
        if case .errorOnViolation = policy {
            // Expected
        } else {
            Issue.record("Expected .errorOnViolation case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Mode.Policy.Test.Unit {
    @Test("Policy is Sendable")
    func isSendable() {
        let policy: any Sendable = Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        #expect(policy is Kernel.File.Direct.Mode.Policy)
    }

    @Test("Policy is Equatable")
    func isEquatable() {
        let a = Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        let b = Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        let c = Kernel.File.Direct.Mode.Policy.errorOnViolation
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Mode.Policy.Test.EdgeCase {
    @Test("all policies are distinct")
    func allPoliciesDistinct() {
        let fallback = Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        let error = Kernel.File.Direct.Mode.Policy.errorOnViolation
        #expect(fallback != error)
    }
}
