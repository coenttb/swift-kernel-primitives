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

extension Kernel.Descriptor.Validity.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Descriptor.Validity.Error.Test.Unit {
    @Test("Error type exists")
    func typeExists() {
        let _: Kernel.Descriptor.Validity.Error.Type = Kernel.Descriptor.Validity.Error.self
    }

    @Test("invalid case exists")
    func invalidCase() {
        let error = Kernel.Descriptor.Validity.Error.invalid
        if case .invalid = error {
            // Expected
        } else {
            Issue.record("Expected .invalid case")
        }
    }

    @Test("limit case exists")
    func limitCase() {
        let error = Kernel.Descriptor.Validity.Error.limit(.process)
        if case .limit(let limit) = error {
            #expect(limit == .process)
        } else {
            Issue.record("Expected .limit case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Descriptor.Validity.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isError() {
        let error: any Swift.Error = Kernel.Descriptor.Validity.Error.invalid
        #expect(error is Kernel.Descriptor.Validity.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let value: any Sendable = Kernel.Descriptor.Validity.Error.invalid
        #expect(value is Kernel.Descriptor.Validity.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.Descriptor.Validity.Error.invalid
        let b = Kernel.Descriptor.Validity.Error.invalid
        let c = Kernel.Descriptor.Validity.Error.limit(.process)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Error is Hashable")
    func isHashable() {
        var set = Set<Kernel.Descriptor.Validity.Error>()
        set.insert(.invalid)
        set.insert(.limit(.process))
        set.insert(.limit(.system))
        set.insert(.invalid)  // duplicate
        #expect(set.count == 3)
    }
}

// MARK: - Description Tests

extension Kernel.Descriptor.Validity.Error.Test.Unit {
    @Test("invalid description")
    func invalidDescription() {
        let error = Kernel.Descriptor.Validity.Error.invalid
        #expect(error.description == "invalid descriptor")
    }

    @Test("limit description includes limit type")
    func limitDescription() {
        let processLimit = Kernel.Descriptor.Validity.Error.limit(.process)
        #expect(processLimit.description.contains("process"))

        let systemLimit = Kernel.Descriptor.Validity.Error.limit(.system)
        #expect(systemLimit.description.contains("system"))
    }
}

// MARK: - Edge Cases

extension Kernel.Descriptor.Validity.Error.Test.EdgeCase {
    @Test("Different limit types are not equal")
    func differentLimitTypesNotEqual() {
        let process = Kernel.Descriptor.Validity.Error.limit(.process)
        let system = Kernel.Descriptor.Validity.Error.limit(.system)
        #expect(process != system)
    }

    @Test("invalid and limit are not equal")
    func invalidAndLimitNotEqual() {
        let invalid = Kernel.Descriptor.Validity.Error.invalid
        let limit = Kernel.Descriptor.Validity.Error.limit(.process)
        #expect(invalid != limit)
    }
}
