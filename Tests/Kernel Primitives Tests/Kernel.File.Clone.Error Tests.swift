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

extension Kernel.File.Clone.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Clone.Error.Test.Unit {
    @Test("notSupported case exists")
    func notSupportedCase() {
        let error = Kernel.File.Clone.Error.notSupported
        if case .notSupported = error {
            // Expected
        } else {
            Issue.record("Expected .notSupported case")
        }
    }

    @Test("crossDevice case exists")
    func crossDeviceCase() {
        let error = Kernel.File.Clone.Error.crossDevice
        if case .crossDevice = error {
            // Expected
        } else {
            Issue.record("Expected .crossDevice case")
        }
    }

    @Test("sourceNotFound case exists")
    func sourceNotFoundCase() {
        let error = Kernel.File.Clone.Error.sourceNotFound
        if case .sourceNotFound = error {
            // Expected
        } else {
            Issue.record("Expected .sourceNotFound case")
        }
    }

    @Test("destinationExists case exists")
    func destinationExistsCase() {
        let error = Kernel.File.Clone.Error.destinationExists
        if case .destinationExists = error {
            // Expected
        } else {
            Issue.record("Expected .destinationExists case")
        }
    }

    @Test("permissionDenied case exists")
    func permissionDeniedCase() {
        let error = Kernel.File.Clone.Error.permissionDenied
        if case .permissionDenied = error {
            // Expected
        } else {
            Issue.record("Expected .permissionDenied case")
        }
    }

    @Test("isDirectory case exists")
    func isDirectoryCase() {
        let error = Kernel.File.Clone.Error.isDirectory
        if case .isDirectory = error {
            // Expected
        } else {
            Issue.record("Expected .isDirectory case")
        }
    }

    @Test("platform case exists")
    func platformCase() {
        let error = Kernel.File.Clone.Error.platform(code: .posix(1), operation: .clonefile)
        if case .platform = error {
            // Expected
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.File.Clone.Error.Test.Unit {
    @Test("notSupported description")
    func notSupportedDescription() {
        let error = Kernel.File.Clone.Error.notSupported
        #expect(error.description == "Reflink not supported on this filesystem")
    }

    @Test("crossDevice description")
    func crossDeviceDescription() {
        let error = Kernel.File.Clone.Error.crossDevice
        #expect(error.description == "Source and destination are on different devices")
    }

    @Test("sourceNotFound description")
    func sourceNotFoundDescription() {
        let error = Kernel.File.Clone.Error.sourceNotFound
        #expect(error.description == "Source file not found")
    }

    @Test("destinationExists description")
    func destinationExistsDescription() {
        let error = Kernel.File.Clone.Error.destinationExists
        #expect(error.description == "Destination already exists")
    }

    @Test("permissionDenied description")
    func permissionDeniedDescription() {
        let error = Kernel.File.Clone.Error.permissionDenied
        #expect(error.description == "Permission denied")
    }

    @Test("isDirectory description")
    func isDirectoryDescription() {
        let error = Kernel.File.Clone.Error.isDirectory
        #expect(error.description == "Source is a directory")
    }

    @Test("platform description includes operation")
    func platformDescription() {
        let error = Kernel.File.Clone.Error.platform(code: .posix(1), operation: .clonefile)
        #expect(error.description.contains("clonefile"))
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Clone.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.File.Clone.Error.notSupported
        #expect(error is Kernel.File.Clone.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.File.Clone.Error.notSupported
        #expect(error is Kernel.File.Clone.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.File.Clone.Error.notSupported
        let b = Kernel.File.Clone.Error.notSupported
        let c = Kernel.File.Clone.Error.crossDevice
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Error is CustomStringConvertible")
    func isCustomStringConvertible() {
        let error: any CustomStringConvertible = Kernel.File.Clone.Error.notSupported
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Nested Types

extension Kernel.File.Clone.Error.Test.Unit {
    @Test("Operation type exists")
    func operationTypeExists() {
        let _: Kernel.File.Clone.Error.Operation.Type = Kernel.File.Clone.Error.Operation.self
    }

    @Test("Syscall type exists")
    func syscallTypeExists() {
        let _: Kernel.File.Clone.Error.Syscall.Type = Kernel.File.Clone.Error.Syscall.self
    }
}

// MARK: - Edge Cases

extension Kernel.File.Clone.Error.Test.EdgeCase {
    @Test("all simple cases are distinct")
    func allSimpleCasesDistinct() {
        let cases: [Kernel.File.Clone.Error] = [
            .notSupported,
            .crossDevice,
            .sourceNotFound,
            .destinationExists,
            .permissionDenied,
            .isDirectory,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("platform errors with different codes are distinct")
    func platformErrorsDistinct() {
        let error1 = Kernel.File.Clone.Error.platform(code: .posix(1), operation: .clonefile)
        let error2 = Kernel.File.Clone.Error.platform(code: .posix(2), operation: .clonefile)
        #expect(error1 != error2)
    }

    @Test("platform errors with different operations are distinct")
    func platformOperationsDistinct() {
        let error1 = Kernel.File.Clone.Error.platform(code: .posix(1), operation: .clonefile)
        let error2 = Kernel.File.Clone.Error.platform(code: .posix(1), operation: .copyfile)
        #expect(error1 != error2)
    }

    @Test("all descriptions are non-empty")
    func allDescriptionsNonEmpty() {
        let cases: [Kernel.File.Clone.Error] = [
            .notSupported,
            .crossDevice,
            .sourceNotFound,
            .destinationExists,
            .permissionDenied,
            .isDirectory,
            .platform(code: .posix(1), operation: .clonefile),
        ]

        for error in cases {
            #expect(!error.description.isEmpty)
        }
    }
}
