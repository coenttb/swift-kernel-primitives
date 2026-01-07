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

extension Kernel.Failure {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Failure.Test.Unit {
    @Test("error conforms to Swift.Error")
    func conformsToError() {
        let error: any Swift.Error = Kernel.Failure.path(.notFound)
        #expect(error is Kernel.Failure)
    }

    @Test("error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.Failure.path(.notFound)
        #expect(error is Kernel.Failure)
    }

    @Test("error is Equatable")
    func isEquatable() {
        #expect(Kernel.Failure.path(.notFound) == Kernel.Failure.path(.notFound))
        #expect(Kernel.Failure.path(.notFound) != Kernel.Failure.permission(.denied))
    }

    @Test("platform error stores code")
    func platformError() {
        let error = Kernel.Failure.platform(.unmapped(code: .posix(42), message: nil))
        if case .platform(let platformError) = error {
            if case .unmapped(let code, _) = platformError {
                #expect(code == .posix(42))
            } else {
                Issue.record("Expected unmapped platform error")
            }
        } else {
            Issue.record("Expected platform error case")
        }
    }

    @Test("all error categories are distinct")
    func errorCategoriesDistinct() {
        var categories: [Kernel.Failure] = [
            .path(.notFound),
            .handle(.invalid),
            .io(.broken),
            .lock(.deadlock),
            .memory(.fault),
            .permission(.denied),
            .space(.exhausted),
            .blocking(.wouldBlock),
            .platform(.unmapped(code: .posix(0), message: nil)),
        ]

        for (i, a) in categories.enumerated() {
            for (j, b) in categories.enumerated() {
                if i != j {
                    #expect(a != b, "Categories at index \(i) and \(j) should be different")
                }
            }
        }
    }

    @Test("Path.Resolution.Error cases are distinct")
    func pathCasesDistinct() {
        let cases: [Kernel.Path.Resolution.Error] = [.notFound, .exists, .isDirectory, .notDirectory, .notEmpty, .crossDevice, .loop, .nameTooLong]
        for (i, a) in cases.enumerated() {
            for (j, b) in cases.enumerated() {
                if i != j {
                    #expect(a != b)
                }
            }
        }
    }

    @Test("Handle.Error cases are distinct")
    func handleCasesDistinct() {
        #expect(Kernel.Descriptor.Validity.Error.invalid != Kernel.Descriptor.Validity.Error.limit(.process))
        #expect(Kernel.Descriptor.Validity.Error.limit(.process) != Kernel.Descriptor.Validity.Error.limit(.system))
    }

    @Test("IO.Error cases are distinct")
    func ioCasesDistinct() {
        let cases: [Kernel.IO.Error] = [.broken, .reset, .hardware, .illegalSeek, .deviceUnsupported, .deviceUnavailable, .unsupported]
        for (i, a) in cases.enumerated() {
            for (j, b) in cases.enumerated() {
                if i != j {
                    #expect(a != b)
                }
            }
        }
    }

    @Test("Lock.Error cases are distinct")
    func lockCasesDistinct() {
        #expect(Kernel.Lock.Error.deadlock != Kernel.Lock.Error.unavailable)
        #expect(Kernel.Lock.Error.contention != Kernel.Lock.Error.deadlock)
    }

    @Test("Memory.Error cases are distinct")
    func memoryCasesDistinct() {
        #expect(Kernel.Memory.Error.fault != Kernel.Memory.Error.exhausted)
    }

    @Test("Permission.Error cases are distinct")
    func permissionCasesDistinct() {
        let cases: [Kernel.Permission.Error] = [.denied, .notPermitted, .readOnlyFilesystem]
        for (i, a) in cases.enumerated() {
            for (j, b) in cases.enumerated() {
                if i != j {
                    #expect(a != b)
                }
            }
        }
    }

    @Test("Space.Error cases are distinct")
    func spaceCasesDistinct() {
        #expect(Kernel.Storage.Error.exhausted != Kernel.Storage.Error.quota)
    }
}

// MARK: - Edge Cases

extension Kernel.Failure.Test.EdgeCase {
    @Test("description is non-empty for all error categories")
    func descriptionNonEmpty() {
        var cases: [Kernel.Failure] = [
            .path(.notFound),
            .path(.exists),
            .path(.isDirectory),
            .path(.notDirectory),
            .path(.notEmpty),
            .path(.crossDevice),
            .path(.loop),
            .path(.nameTooLong),
            .handle(.invalid),
            .handle(.limit(.process)),
            .handle(.limit(.system)),
            .io(.broken),
            .io(.reset),
            .io(.hardware),
            .io(.illegalSeek),
            .io(.deviceUnsupported),
            .io(.deviceUnavailable),
            .io(.unsupported),
            .lock(.deadlock),
            .lock(.unavailable),
            .lock(.contention),
            .memory(.fault),
            .memory(.exhausted),
            .permission(.denied),
            .permission(.notPermitted),
            .permission(.readOnlyFilesystem),
            .space(.exhausted),
            .space(.quota),
            .blocking(.wouldBlock),
            .platform(.unmapped(code: .posix(0), message: nil)),
        ]

        for error in cases {
            #expect(!error.description.isEmpty, "\(error) should have non-empty description")
        }
    }

    @Test("platform error description contains code")
    func platformErrorDescription() {
        let error = Kernel.Failure.platform(.unmapped(code: .posix(-1), message: nil))
        #expect(error.description.contains("-1") || error.description.contains("posix"))
    }
}
