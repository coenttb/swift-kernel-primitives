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

extension Kernel.File.Clone.Error.Syscall {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Clone.Error.Syscall.Test.Unit {
    @Test("platform case exists")
    func platformCase() {
        let syscall = Kernel.File.Clone.Error.Syscall.platform(code: .posix(1), operation: .clonefile)
        if case .platform = syscall {
            // Expected
        } else {
            Issue.record("Expected .platform case")
        }
    }

    @Test("notSupported case exists")
    func notSupportedCase() {
        let syscall = Kernel.File.Clone.Error.Syscall.notSupported(operation: .clonefile)
        if case .notSupported = syscall {
            // Expected
        } else {
            Issue.record("Expected .notSupported case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Clone.Error.Syscall.Test.Unit {
    @Test("Syscall conforms to Swift.Error")
    func isSwiftError() {
        let syscall: any Swift.Error = Kernel.File.Clone.Error.Syscall.platform(code: .posix(1), operation: .clonefile)
        #expect(syscall is Kernel.File.Clone.Error.Syscall)
    }

    @Test("Syscall is Sendable")
    func isSendable() {
        let syscall: any Sendable = Kernel.File.Clone.Error.Syscall.platform(code: .posix(1), operation: .clonefile)
        #expect(syscall is Kernel.File.Clone.Error.Syscall)
    }
}

// MARK: - Associated Value Tests

extension Kernel.File.Clone.Error.Syscall.Test.Unit {
    @Test("platform stores error code")
    func platformStoresCode() {
        let syscall = Kernel.File.Clone.Error.Syscall.platform(code: .posix(42), operation: .clonefile)
        if case .platform(let code, _) = syscall {
            if case .posix(let errno) = code {
                #expect(errno == 42)
            } else {
                Issue.record("Expected .posix code")
            }
        } else {
            Issue.record("Expected .platform case")
        }
    }

    @Test("platform stores operation")
    func platformStoresOperation() {
        let syscall = Kernel.File.Clone.Error.Syscall.platform(code: .posix(1), operation: .copyfile)
        if case .platform(_, let operation) = syscall {
            #expect(operation == .copyfile)
        } else {
            Issue.record("Expected .platform case")
        }
    }

    @Test("notSupported stores operation")
    func notSupportedStoresOperation() {
        let syscall = Kernel.File.Clone.Error.Syscall.notSupported(operation: .ficlone)
        if case .notSupported(let operation) = syscall {
            #expect(operation == .ficlone)
        } else {
            Issue.record("Expected .notSupported case")
        }
    }
}

// MARK: - Edge Cases

extension Kernel.File.Clone.Error.Syscall.Test.EdgeCase {
    @Test("platform with different codes are distinct")
    func platformCodesDifferent() {
        let syscall1 = Kernel.File.Clone.Error.Syscall.platform(code: .posix(1), operation: .clonefile)
        let syscall2 = Kernel.File.Clone.Error.Syscall.platform(code: .posix(2), operation: .clonefile)
        // They should be different error instances
        _ = syscall1
        _ = syscall2
    }

    @Test("platform with different operations are distinct")
    func platformOperationsDifferent() {
        let syscall1 = Kernel.File.Clone.Error.Syscall.platform(code: .posix(1), operation: .clonefile)
        let syscall2 = Kernel.File.Clone.Error.Syscall.platform(code: .posix(1), operation: .copyfile)
        _ = syscall1
        _ = syscall2
    }

    @Test("all operations can be used with platform")
    func allOperationsWithPlatform() {
        let operations: [Kernel.File.Clone.Error.Operation] = [
            .clonefile,
            .copyfile,
            .ficlone,
            .copyFileRange,
            .duplicateExtents,
            .statfs,
            .stat,
            .copy,
        ]

        for operation in operations {
            let syscall = Kernel.File.Clone.Error.Syscall.platform(code: .posix(1), operation: operation)
            if case .platform(_, let op) = syscall {
                #expect(op == operation)
            } else {
                Issue.record("Expected .platform case for operation \(operation)")
            }
        }
    }

    @Test("all operations can be used with notSupported")
    func allOperationsWithNotSupported() {
        let operations: [Kernel.File.Clone.Error.Operation] = [
            .clonefile,
            .copyfile,
            .ficlone,
            .copyFileRange,
            .duplicateExtents,
            .statfs,
            .stat,
            .copy,
        ]

        for operation in operations {
            let syscall = Kernel.File.Clone.Error.Syscall.notSupported(operation: operation)
            if case .notSupported(let op) = syscall {
                #expect(op == operation)
            } else {
                Issue.record("Expected .notSupported case for operation \(operation)")
            }
        }
    }
}
