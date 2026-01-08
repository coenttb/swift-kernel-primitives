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

extension Kernel.File.System.Stats.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.System.Stats.Error.Test.Unit {
    @Test("path case exists")
    func pathCase() {
        let error = Kernel.File.System.Stats.Error.path(.notFound)
        if case .path = error {
            // Expected
        } else {
            Issue.record("Expected .path case")
        }
    }

    @Test("handle case exists")
    func handleCase() {
        let error = Kernel.File.System.Stats.Error.handle(.invalid)
        if case .handle = error {
            // Expected
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test("permission case exists")
    func permissionCase() {
        let error = Kernel.File.System.Stats.Error.permission(.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission case")
        }
    }

    @Test("memory case exists")
    func memoryCase() {
        let error = Kernel.File.System.Stats.Error.memory(.exhausted)
        if case .memory = error {
            // Expected
        } else {
            Issue.record("Expected .memory case")
        }
    }

    @Test("io case exists")
    func ioCase() {
        let error = Kernel.File.System.Stats.Error.io(.hardware)
        if case .io = error {
            // Expected
        } else {
            Issue.record("Expected .io case")
        }
    }

    @Test("platform case exists")
    func platformCase() {
        let code = Kernel.Error.Code.posix(999)
        let unmapped = Kernel.Error(code: code)
        let error = Kernel.File.System.Stats.Error.platform(unmapped)
        if case .platform = error {
            // Expected
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.File.System.Stats.Error.Test.Unit {
    @Test("path description format")
    func pathDescription() {
        let error = Kernel.File.System.Stats.Error.path(.notFound)
        #expect(error.description.contains("path:"))
    }

    @Test("handle description format")
    func handleDescription() {
        let error = Kernel.File.System.Stats.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

    @Test("permission description format")
    func permissionDescription() {
        let error = Kernel.File.System.Stats.Error.permission(.denied)
        #expect(error.description.contains("permission:"))
    }

    @Test("memory description format")
    func memoryDescription() {
        let error = Kernel.File.System.Stats.Error.memory(.exhausted)
        #expect(error.description.contains("memory:"))
    }

    @Test("io description format")
    func ioDescription() {
        let error = Kernel.File.System.Stats.Error.io(.hardware)
        #expect(error.description.contains("io:"))
    }
}

// MARK: - Conformance Tests

extension Kernel.File.System.Stats.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.File.System.Stats.Error.handle(.invalid)
        #expect(error is Kernel.File.System.Stats.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.File.System.Stats.Error.handle(.invalid)
        #expect(error is Kernel.File.System.Stats.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.File.System.Stats.Error.handle(.invalid)
        let b = Kernel.File.System.Stats.Error.handle(.invalid)
        let c = Kernel.File.System.Stats.Error.io(.hardware)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Error is CustomStringConvertible")
    func isCustomStringConvertible() {
        let error: any CustomStringConvertible = Kernel.File.System.Stats.Error.handle(.invalid)
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Edge Cases

extension Kernel.File.System.Stats.Error.Test.EdgeCase {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let code = Kernel.Error.Code.posix(999)
        let unmapped = Kernel.Error(code: code)

        let cases: [Kernel.File.System.Stats.Error] = [
            .path(.notFound),
            .handle(.invalid),
            .permission(.denied),
            .memory(.exhausted),
            .io(.hardware),
            .platform(unmapped),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("different path errors are distinct")
    func pathErrorsDistinct() {
        let notFound = Kernel.File.System.Stats.Error.path(.notFound)
        let tooLong = Kernel.File.System.Stats.Error.path(.nameTooLong)
        #expect(notFound != tooLong)
    }

    @Test("different handle errors are distinct")
    func handleErrorsDistinct() {
        let invalid = Kernel.File.System.Stats.Error.handle(.invalid)
        let processLimit = Kernel.File.System.Stats.Error.handle(.limit(.process))
        #expect(invalid != processLimit)
    }

    @Test("different io errors are distinct")
    func ioErrorsDistinct() {
        let hardware = Kernel.File.System.Stats.Error.io(.hardware)
        let broken = Kernel.File.System.Stats.Error.io(.broken)
        #expect(hardware != broken)
    }

    @Test("all descriptions are non-empty")
    func allDescriptionsNonEmpty() {
        let code = Kernel.Error.Code.posix(999)
        let unmapped = Kernel.Error(code: code)

        let cases: [Kernel.File.System.Stats.Error] = [
            .path(.notFound),
            .handle(.invalid),
            .permission(.denied),
            .memory(.exhausted),
            .io(.hardware),
            .platform(unmapped),
        ]

        for error in cases {
            #expect(!error.description.isEmpty)
        }
    }
}
