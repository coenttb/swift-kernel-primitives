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

extension Kernel.IO.Blocking.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.IO.Blocking.Error.Test.Unit {
    @Test("wouldBlock case exists")
    func wouldBlockCase() {
        let error = Kernel.IO.Blocking.Error.wouldBlock
        if case .wouldBlock = error {
            // Expected
        } else {
            Issue.record("Expected .wouldBlock case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.IO.Blocking.Error.Test.Unit {
    @Test("wouldBlock description")
    func wouldBlockDescription() {
        let error = Kernel.IO.Blocking.Error.wouldBlock
        #expect(error.description == "operation would block")
    }
}

// MARK: - Conformance Tests

extension Kernel.IO.Blocking.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.IO.Blocking.Error.wouldBlock
        #expect(error is Kernel.IO.Blocking.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.IO.Blocking.Error.wouldBlock
        #expect(error is Kernel.IO.Blocking.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.IO.Blocking.Error.wouldBlock
        let b = Kernel.IO.Blocking.Error.wouldBlock
        #expect(a == b)
    }

    @Test("Error is Hashable")
    func isHashable() {
        var set = Set<Kernel.IO.Blocking.Error>()
        set.insert(.wouldBlock)
        set.insert(.wouldBlock)  // duplicate
        #expect(set.count == 1)
    }
}
