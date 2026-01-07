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

extension Kernel.File.Open.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Open.Error.Test.Unit {
    @Test("path case stores Path.Resolution.Error")
    func pathCase() {
        let pathError = Kernel.Path.Resolution.Error.notFound
        let error = Kernel.File.Open.Error.path(pathError)
        if case .path(let stored) = error {
            #expect(stored == pathError)
        } else {
            Issue.record("Expected .path case")
        }
    }

    @Test("permission case stores Permission.Error")
    func permissionCase() {
        let permError = Kernel.Permission.Error.denied
        let error = Kernel.File.Open.Error.permission(permError)
        if case .permission(let stored) = error {
            #expect(stored == permError)
        } else {
            Issue.record("Expected .permission case")
        }
    }

    @Test("handle case stores Descriptor.Validity.Error")
    func handleCase() {
        let handleError = Kernel.Descriptor.Validity.Error.invalid
        let error = Kernel.File.Open.Error.handle(handleError)
        if case .handle(let stored) = error {
            #expect(stored == handleError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test("space case stores Storage.Error")
    func spaceCase() {
        let spaceError = Kernel.Storage.Error.exhausted
        let error = Kernel.File.Open.Error.space(spaceError)
        if case .space(let stored) = error {
            #expect(stored == spaceError)
        } else {
            Issue.record("Expected .space case")
        }
    }

    @Test("io case stores IO.Error")
    func ioCase() {
        let ioError = Kernel.IO.Error.hardware
        let error = Kernel.File.Open.Error.io(ioError)
        if case .io(let stored) = error {
            #expect(stored == ioError)
        } else {
            Issue.record("Expected .io case")
        }
    }

    @Test("platform case stores Errno.Unmapped.Error")
    func platformCase() {
        let code = Kernel.Error.Code.posix(999)
        let unmappedError = Kernel.Error.Unmapped.Error.unmapped(code: code, message: nil)
        let error = Kernel.File.Open.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.File.Open.Error.Test.Unit {
    @Test("path description format")
    func pathDescription() {
        let error = Kernel.File.Open.Error.path(.notFound)
        #expect(error.description.contains("path:"))
    }

    @Test("permission description format")
    func permissionDescription() {
        let error = Kernel.File.Open.Error.permission(.denied)
        #expect(error.description.contains("permission:"))
    }

    @Test("handle description format")
    func handleDescription() {
        let error = Kernel.File.Open.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

    @Test("space description format")
    func spaceDescription() {
        let error = Kernel.File.Open.Error.space(.exhausted)
        #expect(error.description.contains("space:"))
    }

    @Test("io description format")
    func ioDescription() {
        let error = Kernel.File.Open.Error.io(.hardware)
        #expect(error.description.contains("io:"))
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Open.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.File.Open.Error.path(.notFound)
        #expect(error is Kernel.File.Open.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.File.Open.Error.path(.notFound)
        #expect(error is Kernel.File.Open.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.File.Open.Error.path(.notFound)
        let b = Kernel.File.Open.Error.path(.notFound)
        let c = Kernel.File.Open.Error.path(.exists)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Open.Error.Test.EdgeCase {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.File.Open.Error] = [
            .path(.notFound),
            .permission(.denied),
            .handle(.invalid),
            .space(.exhausted),
            .io(.hardware),
            .platform(.unmapped(code: .posix(1), message: nil)),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("path resolution cases are distinct")
    func pathResolutionCasesDistinct() {
        let notFound = Kernel.File.Open.Error.path(.notFound)
        let exists = Kernel.File.Open.Error.path(.exists)
        let isDirectory = Kernel.File.Open.Error.path(.isDirectory)
        #expect(notFound != exists)
        #expect(exists != isDirectory)
    }

    @Test("permission cases are distinct")
    func permissionCasesDistinct() {
        let denied = Kernel.File.Open.Error.permission(.denied)
        let notPermitted = Kernel.File.Open.Error.permission(.notPermitted)
        let readOnly = Kernel.File.Open.Error.permission(.readOnlyFilesystem)
        #expect(denied != notPermitted)
        #expect(notPermitted != readOnly)
    }
}
