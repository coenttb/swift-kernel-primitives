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

extension Kernel.Lock.Kind {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Lock.Kind.Test.Unit {
    @Test("shared case exists")
    func sharedCase() {
        let kind = Kernel.Lock.Kind.shared
        if case .shared = kind {
            // Expected
        } else {
            Issue.record("Expected .shared case")
        }
    }

    @Test("exclusive case exists")
    func exclusiveCase() {
        let kind = Kernel.Lock.Kind.exclusive
        if case .exclusive = kind {
            // Expected
        } else {
            Issue.record("Expected .exclusive case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Lock.Kind.Test.Unit {
    @Test("Kind is Sendable")
    func isSendable() {
        let kind: any Sendable = Kernel.Lock.Kind.shared
        #expect(kind is Kernel.Lock.Kind)
    }

    @Test("Kind is Equatable")
    func isEquatable() {
        let a = Kernel.Lock.Kind.shared
        let b = Kernel.Lock.Kind.shared
        let c = Kernel.Lock.Kind.exclusive
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Kind is Hashable")
    func isHashable() {
        var set = Set<Kernel.Lock.Kind>()
        set.insert(.shared)
        set.insert(.exclusive)
        set.insert(.shared)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Lock.Kind.Test.EdgeCase {
    @Test("shared and exclusive are distinct")
    func casesDistinct() {
        let shared = Kernel.Lock.Kind.shared
        let exclusive = Kernel.Lock.Kind.exclusive
        #expect(shared != exclusive)
    }

    @Test("hash values for different kinds are different")
    func hashValuesDistinct() {
        let sharedHash = Kernel.Lock.Kind.shared.hashValue
        let exclusiveHash = Kernel.Lock.Kind.exclusive.hashValue
        #expect(sharedHash != exclusiveHash)
    }
}
