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

extension Kernel.Unlink.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Unlink.Error.Test.Unit {
    @Test("Error type exists")
    func typeExists() {
        let _: Kernel.Unlink.Error.Type = Kernel.Unlink.Error.self
    }

    @Test("path case exists")
    func pathCase() {
        let pathError = Kernel.Path.Resolution.Error.notFound
        let error = Kernel.Unlink.Error.path(pathError)
        if case .path(let e) = error {
            #expect(e == pathError)
        } else {
            Issue.record("Expected .path case")
        }
    }

    @Test("permission case exists")
    func permissionCase() {
        let permissionError = Kernel.Permission.Error.denied
        let error = Kernel.Unlink.Error.permission(permissionError)
        if case .permission(let e) = error {
            #expect(e == permissionError)
        } else {
            Issue.record("Expected .permission case")
        }
    }

    @Test("io case exists")
    func ioCase() {
        let ioError = Kernel.IO.Error.hardware
        let error = Kernel.Unlink.Error.io(ioError)
        if case .io(let e) = error {
            #expect(e == ioError)
        } else {
            Issue.record("Expected .io case")
        }
    }

    @Test("platform case exists")
    func platformCase() {
        let platformError = Kernel.Error.Unmapped.Error.unmapped(code: .posix(999), message: nil)
        let error = Kernel.Unlink.Error.platform(platformError)
        if case .platform(let e) = error {
            #expect(e == platformError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Unlink.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isError() {
        let error: any Swift.Error = Kernel.Unlink.Error.path(.notFound)
        #expect(error is Kernel.Unlink.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let value: any Sendable = Kernel.Unlink.Error.path(.notFound)
        #expect(value is Kernel.Unlink.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.Unlink.Error.path(.notFound)
        let b = Kernel.Unlink.Error.path(.notFound)
        let c = Kernel.Unlink.Error.path(.exists)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Description Tests

extension Kernel.Unlink.Error.Test.Unit {
    @Test("path error description contains 'path'")
    func pathDescription() {
        let error = Kernel.Unlink.Error.path(.notFound)
        #expect(error.description.contains("path"))
    }

    @Test("permission error description contains 'permission'")
    func permissionDescription() {
        let error = Kernel.Unlink.Error.permission(.denied)
        #expect(error.description.contains("permission"))
    }

    @Test("io error description contains 'io'")
    func ioDescription() {
        let error = Kernel.Unlink.Error.io(.hardware)
        #expect(error.description.contains("io"))
    }
}

// MARK: - Edge Cases

extension Kernel.Unlink.Error.Test.EdgeCase {
    @Test("Different cases are not equal")
    func differentCasesNotEqual() {
        let pathError = Kernel.Unlink.Error.path(.notFound)
        let permissionError = Kernel.Unlink.Error.permission(.denied)
        let ioError = Kernel.Unlink.Error.io(.hardware)
        #expect(pathError != permissionError)
        #expect(pathError != ioError)
        #expect(permissionError != ioError)
    }
}
