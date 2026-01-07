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

extension Kernel.Storage.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Storage.Error.Test.Unit {
    @Test("Error type exists")
    func typeExists() {
        let _: Kernel.Storage.Error.Type = Kernel.Storage.Error.self
    }

    @Test("exhausted case exists")
    func exhaustedCase() {
        let error = Kernel.Storage.Error.exhausted
        if case .exhausted = error {
            // Expected
        } else {
            Issue.record("Expected .exhausted case")
        }
    }

    @Test("quota case exists")
    func quotaCase() {
        let error = Kernel.Storage.Error.quota
        if case .quota = error {
            // Expected
        } else {
            Issue.record("Expected .quota case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Storage.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isError() {
        let error: any Swift.Error = Kernel.Storage.Error.exhausted
        #expect(error is Kernel.Storage.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let value: any Sendable = Kernel.Storage.Error.exhausted
        #expect(value is Kernel.Storage.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.Storage.Error.exhausted
        let b = Kernel.Storage.Error.exhausted
        let c = Kernel.Storage.Error.quota
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Error is Hashable")
    func isHashable() {
        var set = Set<Kernel.Storage.Error>()
        set.insert(.exhausted)
        set.insert(.quota)
        set.insert(.exhausted)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Description Tests

extension Kernel.Storage.Error.Test.Unit {
    @Test("exhausted description")
    func exhaustedDescription() {
        let error = Kernel.Storage.Error.exhausted
        #expect(error.description == "no space left on device")
    }

    @Test("quota description")
    func quotaDescription() {
        let error = Kernel.Storage.Error.quota
        #expect(error.description == "disk quota exceeded")
    }
}

// MARK: - Edge Cases

extension Kernel.Storage.Error.Test.EdgeCase {
    @Test("All cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.Storage.Error] = [.exhausted, .quota]
        let uniqueCases = Set(cases)
        #expect(uniqueCases.count == cases.count)
    }

    @Test("CustomStringConvertible works for all cases")
    func customStringConvertibleAllCases() {
        let cases: [Kernel.Storage.Error] = [.exhausted, .quota]
        for error in cases {
            let description = String(describing: error)
            #expect(!description.isEmpty)
        }
    }
}
