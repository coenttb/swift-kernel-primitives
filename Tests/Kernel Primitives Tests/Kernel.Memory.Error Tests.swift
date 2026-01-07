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

extension Kernel.Memory.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Memory.Error.Test.Unit {
    @Test("fault case exists")
    func faultCase() {
        let error = Kernel.Memory.Error.fault
        if case .fault = error {
            // Expected
        } else {
            Issue.record("Expected .fault case")
        }
    }

    @Test("exhausted case exists")
    func exhaustedCase() {
        let error = Kernel.Memory.Error.exhausted
        if case .exhausted = error {
            // Expected
        } else {
            Issue.record("Expected .exhausted case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.Memory.Error.Test.Unit {
    @Test("fault description")
    func faultDescription() {
        #expect(Kernel.Memory.Error.fault.description == "bad address")
    }

    @Test("exhausted description")
    func exhaustedDescription() {
        #expect(Kernel.Memory.Error.exhausted.description == "out of memory")
    }
}

// MARK: - Conformance Tests

extension Kernel.Memory.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.Memory.Error.fault
        #expect(error is Kernel.Memory.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.Memory.Error.fault
        #expect(error is Kernel.Memory.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        #expect(Kernel.Memory.Error.fault == .fault)
        #expect(Kernel.Memory.Error.exhausted == .exhausted)
        #expect(Kernel.Memory.Error.fault != .exhausted)
    }

    @Test("Error is Hashable")
    func isHashable() {
        var set = Set<Kernel.Memory.Error>()
        set.insert(.fault)
        set.insert(.exhausted)
        set.insert(.fault)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Memory.Error.Test.EdgeCase {
    @Test("cases are distinct")
    func casesDistinct() {
        #expect(Kernel.Memory.Error.fault != .exhausted)
    }

    @Test("descriptions are distinct")
    func descriptionsDistinct() {
        #expect(Kernel.Memory.Error.fault.description != Kernel.Memory.Error.exhausted.description)
    }
}
