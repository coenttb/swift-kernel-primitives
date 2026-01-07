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

extension Kernel.Socket.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Socket.Error.Test.Unit {
    @Test("Error type exists")
    func typeExists() {
        let _: Kernel.Socket.Error.Type = Kernel.Socket.Error.self
    }

    @Test("handle case exists")
    func handleCase() {
        let handleError = Kernel.Descriptor.Validity.Error.invalid
        let error = Kernel.Socket.Error.handle(handleError)
        if case .handle(let e) = error {
            #expect(e == handleError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test("platform case exists")
    func platformCase() {
        let platformError = Kernel.Error.Unmapped.Error.unmapped(code: .posix(999), message: nil)
        let error = Kernel.Socket.Error.platform(platformError)
        if case .platform(let e) = error {
            #expect(e == platformError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Socket.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isError() {
        let error: any Swift.Error = Kernel.Socket.Error.handle(.invalid)
        #expect(error is Kernel.Socket.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let value: any Sendable = Kernel.Socket.Error.handle(.invalid)
        #expect(value is Kernel.Socket.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.Socket.Error.handle(.invalid)
        let b = Kernel.Socket.Error.handle(.invalid)
        let c = Kernel.Socket.Error.platform(.unmapped(code: .posix(1), message: nil))
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Description Tests

extension Kernel.Socket.Error.Test.Unit {
    @Test("handle error description contains 'handle'")
    func handleDescription() {
        let error = Kernel.Socket.Error.handle(.invalid)
        #expect(error.description.contains("handle"))
    }

    @Test("platform error description")
    func platformDescription() {
        let platformError = Kernel.Error.Unmapped.Error.unmapped(code: .posix(42), message: nil)
        let error = Kernel.Socket.Error.platform(platformError)
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Edge Cases

extension Kernel.Socket.Error.Test.EdgeCase {
    @Test("Different cases are not equal")
    func differentCasesNotEqual() {
        let handleError = Kernel.Socket.Error.handle(.invalid)
        let platformError = Kernel.Socket.Error.platform(
            .unmapped(code: .posix(1), message: nil)
        )
        #expect(handleError != platformError)
    }
}
