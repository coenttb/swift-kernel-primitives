// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import StandardsTestSupport
import Testing

@testable import Kernel_Primitives

extension Kernel.Descriptor.Validity.Error.Limit {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Descriptor.Validity.Error.Limit.Test.Unit {
    @Test("Limit type exists")
    func typeExists() {
        let _: Kernel.Descriptor.Validity.Error.Limit.Type = Kernel.Descriptor.Validity.Error.Limit.self
    }

    @Test("process case exists")
    func processCase() {
        let limit = Kernel.Descriptor.Validity.Error.Limit.process
        if case .process = limit {
            // Expected
        } else {
            Issue.record("Expected .process case")
        }
    }

    @Test("system case exists")
    func systemCase() {
        let limit = Kernel.Descriptor.Validity.Error.Limit.system
        if case .system = limit {
            // Expected
        } else {
            Issue.record("Expected .system case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Descriptor.Validity.Error.Limit.Test.Unit {
    @Test("Limit is Sendable")
    func isSendable() {
        let value: any Sendable = Kernel.Descriptor.Validity.Error.Limit.process
        #expect(value is Kernel.Descriptor.Validity.Error.Limit)
    }

    @Test("Limit is Equatable")
    func isEquatable() {
        let a = Kernel.Descriptor.Validity.Error.Limit.process
        let b = Kernel.Descriptor.Validity.Error.Limit.process
        let c = Kernel.Descriptor.Validity.Error.Limit.system
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Limit is Hashable")
    func isHashable() {
        var set = Set<Kernel.Descriptor.Validity.Error.Limit>()
        set.insert(.process)
        set.insert(.system)
        set.insert(.process)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Description Tests

extension Kernel.Descriptor.Validity.Error.Limit.Test.Unit {
    @Test("process description")
    func processDescription() {
        let limit = Kernel.Descriptor.Validity.Error.Limit.process
        #expect(limit.description == "too many open files in process")
    }

    @Test("system description")
    func systemDescription() {
        let limit = Kernel.Descriptor.Validity.Error.Limit.system
        #expect(limit.description == "too many open files in system")
    }
}

// MARK: - Edge Cases

extension Kernel.Descriptor.Validity.Error.Limit.Test.EdgeCase {
    @Test("All cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.Descriptor.Validity.Error.Limit] = [.process, .system]
        let uniqueCases = Set(cases)
        #expect(uniqueCases.count == cases.count)
    }
}
