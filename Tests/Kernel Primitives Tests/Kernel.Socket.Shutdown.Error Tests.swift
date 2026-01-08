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

extension Kernel.Socket.Shutdown.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Socket.Shutdown.Error.Test.Unit {
    @Test("Error type exists")
    func typeExists() {
        let _: Kernel.Socket.Shutdown.Error.Type = Kernel.Socket.Shutdown.Error.self
    }

    @Test("handle case exists")
    func handleCase() {
        let handleError = Kernel.Descriptor.Validity.Error.invalid
        let error = Kernel.Socket.Shutdown.Error.handle(handleError)
        if case .handle(let e) = error {
            #expect(e == handleError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test("io case exists")
    func ioCase() {
        let ioError = Kernel.IO.Error.broken
        let error = Kernel.Socket.Shutdown.Error.io(ioError)
        if case .io(let e) = error {
            #expect(e == ioError)
        } else {
            Issue.record("Expected .io case")
        }
    }

    @Test("platform case exists")
    func platformCase() {
        let platformError = Kernel.Error(code: .posix(999))
        let error = Kernel.Socket.Shutdown.Error.platform(platformError)
        if case .platform(let e) = error {
            #expect(e == platformError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Socket.Shutdown.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isError() {
        let error: any Swift.Error = Kernel.Socket.Shutdown.Error.handle(.invalid)
        #expect(error is Kernel.Socket.Shutdown.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let value: any Sendable = Kernel.Socket.Shutdown.Error.handle(.invalid)
        #expect(value is Kernel.Socket.Shutdown.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.Socket.Shutdown.Error.handle(.invalid)
        let b = Kernel.Socket.Shutdown.Error.handle(.invalid)
        let c = Kernel.Socket.Shutdown.Error.io(.broken)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Description Tests

extension Kernel.Socket.Shutdown.Error.Test.Unit {
    @Test("handle error description contains 'handle'")
    func handleDescription() {
        let error = Kernel.Socket.Shutdown.Error.handle(.invalid)
        #expect(error.description.contains("handle"))
    }

    @Test("io error description contains 'io'")
    func ioDescription() {
        let error = Kernel.Socket.Shutdown.Error.io(.broken)
        #expect(error.description.contains("io"))
    }

    @Test("platform error description")
    func platformDescription() {
        let platformError = Kernel.Error(code: .posix(42))
        let error = Kernel.Socket.Shutdown.Error.platform(platformError)
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Edge Cases

extension Kernel.Socket.Shutdown.Error.Test.EdgeCase {
    @Test("Different cases are not equal")
    func differentCasesNotEqual() {
        let handleError = Kernel.Socket.Shutdown.Error.handle(.invalid)
        let ioError = Kernel.Socket.Shutdown.Error.io(.broken)
        let platformError = Kernel.Socket.Shutdown.Error.platform(
            Kernel.Error(code: .posix(1))
        )
        #expect(handleError != ioError)
        #expect(handleError != platformError)
        #expect(ioError != platformError)
    }

    @Test("Same case with different values are not equal")
    func sameCaseDifferentValues() {
        let a = Kernel.Socket.Shutdown.Error.io(.broken)
        let b = Kernel.Socket.Shutdown.Error.io(.reset)
        #expect(a != b)
    }
}
