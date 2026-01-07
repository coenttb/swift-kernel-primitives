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

extension Kernel.Permission.Error {
    #TestSuites
}

// MARK: - Permission.Error Tests

extension Kernel.Permission.Error.Test.Unit {
    @Test("denied case exists")
    func deniedCaseExists() {
        let error = Kernel.Permission.Error.denied
        if case .denied = error {
            // Expected
        } else {
            Issue.record("Expected .denied case")
        }
    }

    @Test("notPermitted case exists")
    func notPermittedCaseExists() {
        let error = Kernel.Permission.Error.notPermitted
        if case .notPermitted = error {
            // Expected
        } else {
            Issue.record("Expected .notPermitted case")
        }
    }

    @Test("readOnlyFilesystem case exists")
    func readOnlyFilesystemCaseExists() {
        let error = Kernel.Permission.Error.readOnlyFilesystem
        if case .readOnlyFilesystem = error {
            // Expected
        } else {
            Issue.record("Expected .readOnlyFilesystem case")
        }
    }

    @Test("all cases are distinct")
    func allCasesDistinct() {
        let denied = Kernel.Permission.Error.denied
        let notPermitted = Kernel.Permission.Error.notPermitted
        let readOnly = Kernel.Permission.Error.readOnlyFilesystem

        #expect(denied != notPermitted)
        #expect(denied != readOnly)
        #expect(notPermitted != readOnly)
    }

    @Test("Permission.Error conforms to Swift.Error")
    func conformsToSwiftError() {
        let error: any Swift.Error = Kernel.Permission.Error.denied
        #expect(error is Kernel.Permission.Error)
    }

    @Test("Permission.Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.Permission.Error.denied
        #expect(error is Kernel.Permission.Error)
    }

    @Test("Permission.Error is Equatable")
    func isEquatable() {
        let a = Kernel.Permission.Error.denied
        let b = Kernel.Permission.Error.denied
        let c = Kernel.Permission.Error.notPermitted

        #expect(a == b)
        #expect(a != c)
    }

    @Test("Permission.Error is Hashable")
    func isHashable() {
        var set = Set<Kernel.Permission.Error>()
        set.insert(.denied)
        set.insert(.notPermitted)
        set.insert(.readOnlyFilesystem)
        set.insert(.denied)  // duplicate

        #expect(set.count == 3)
        #expect(set.contains(.denied))
        #expect(set.contains(.notPermitted))
        #expect(set.contains(.readOnlyFilesystem))
    }

    @Test("denied description is meaningful")
    func deniedDescription() {
        let error = Kernel.Permission.Error.denied
        #expect(error.description == "permission denied")
    }

    @Test("notPermitted description is meaningful")
    func notPermittedDescription() {
        let error = Kernel.Permission.Error.notPermitted
        #expect(error.description == "operation not permitted")
    }

    @Test("readOnlyFilesystem description is meaningful")
    func readOnlyFilesystemDescription() {
        let error = Kernel.Permission.Error.readOnlyFilesystem
        #expect(error.description == "read-only filesystem")
    }
}

extension Kernel.Permission.Error.Test.Unit {
    @Test("CustomStringConvertible works for all cases")
    func customStringConvertibleAllCases() {
        let cases: [Kernel.Permission.Error] = [.denied, .notPermitted, .readOnlyFilesystem]

        for error in cases {
            let description = String(describing: error)
            #expect(!description.isEmpty, "Description should not be empty for \(error)")
        }
    }
}
