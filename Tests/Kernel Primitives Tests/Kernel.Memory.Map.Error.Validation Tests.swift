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

extension Kernel.Memory.Map.Error.Validation {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Memory.Map.Error.Validation.Test.Unit {
    @Test("length case exists")
    func lengthCase() {
        let validation = Kernel.Memory.Map.Error.Validation.length
        if case .length = validation {
            // Expected
        } else {
            Issue.record("Expected .length case")
        }
    }

    @Test("alignment case exists")
    func alignmentCase() {
        let validation = Kernel.Memory.Map.Error.Validation.alignment
        if case .alignment = validation {
            // Expected
        } else {
            Issue.record("Expected .alignment case")
        }
    }

    @Test("offset case exists")
    func offsetCase() {
        let validation = Kernel.Memory.Map.Error.Validation.offset
        if case .offset = validation {
            // Expected
        } else {
            Issue.record("Expected .offset case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.Memory.Map.Error.Validation.Test.Unit {
    @Test("length description")
    func lengthDescription() {
        let validation = Kernel.Memory.Map.Error.Validation.length
        #expect(validation.description == "length must be greater than zero")
    }

    @Test("alignment description")
    func alignmentDescription() {
        let validation = Kernel.Memory.Map.Error.Validation.alignment
        #expect(validation.description == "address alignment is invalid")
    }

    @Test("offset description")
    func offsetDescription() {
        let validation = Kernel.Memory.Map.Error.Validation.offset
        #expect(validation.description == "offset is invalid")
    }
}

// MARK: - Conformance Tests

extension Kernel.Memory.Map.Error.Validation.Test.Unit {
    @Test("Validation is Sendable")
    func isSendable() {
        let validation: any Sendable = Kernel.Memory.Map.Error.Validation.length
        #expect(validation is Kernel.Memory.Map.Error.Validation)
    }

    @Test("Validation is Equatable")
    func isEquatable() {
        let a = Kernel.Memory.Map.Error.Validation.length
        let b = Kernel.Memory.Map.Error.Validation.length
        let c = Kernel.Memory.Map.Error.Validation.alignment
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Validation is Hashable")
    func isHashable() {
        var set = Set<Kernel.Memory.Map.Error.Validation>()
        set.insert(.length)
        set.insert(.alignment)
        set.insert(.length)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Memory.Map.Error.Validation.Test.EdgeCase {
    @Test("all validation cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.Memory.Map.Error.Validation] = [
            .length,
            .alignment,
            .offset,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("all descriptions are distinct")
    func allDescriptionsDistinct() {
        let length = Kernel.Memory.Map.Error.Validation.length
        let alignment = Kernel.Memory.Map.Error.Validation.alignment
        let offset = Kernel.Memory.Map.Error.Validation.offset

        #expect(length.description != alignment.description)
        #expect(alignment.description != offset.description)
        #expect(length.description != offset.description)
    }
}

// MARK: - Integration with Error

extension Kernel.Memory.Map.Error.Validation.Test.Unit {
    @Test("Validation can be wrapped in Error.invalid")
    func wrappedInError() {
        let error = Kernel.Memory.Map.Error.invalid(.length)
        if case .invalid(.length) = error {
            // Expected
        } else {
            Issue.record("Expected .invalid(.length)")
        }
    }
}
