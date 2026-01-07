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

extension Kernel.File.Direct.Error.Syscall {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Error.Syscall.Test.Unit {
    @Test("platform case exists")
    func platformCase() {
        let syscall = Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .open)
        if case .platform = syscall {
            // Expected
        } else {
            Issue.record("Expected .platform case")
        }
    }

    @Test("invalidDescriptor case exists")
    func invalidDescriptorCase() {
        let syscall = Kernel.File.Direct.Error.Syscall.invalidDescriptor(operation: .read)
        if case .invalidDescriptor = syscall {
            // Expected
        } else {
            Issue.record("Expected .invalidDescriptor case")
        }
    }

    @Test("alignmentViolation case exists")
    func alignmentViolationCase() {
        let syscall = Kernel.File.Direct.Error.Syscall.alignmentViolation(operation: .write)
        if case .alignmentViolation = syscall {
            // Expected
        } else {
            Issue.record("Expected .alignmentViolation case")
        }
    }

    @Test("notSupported case exists")
    func notSupportedCase() {
        let syscall = Kernel.File.Direct.Error.Syscall.notSupported(operation: .open)
        if case .notSupported = syscall {
            // Expected
        } else {
            Issue.record("Expected .notSupported case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Error.Syscall.Test.Unit {
    @Test("Syscall conforms to Swift.Error")
    func isSwiftError() {
        let syscall: any Swift.Error = Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .open)
        #expect(syscall is Kernel.File.Direct.Error.Syscall)
    }

    @Test("Syscall is Sendable")
    func isSendable() {
        let syscall: any Sendable = Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .open)
        #expect(syscall is Kernel.File.Direct.Error.Syscall)
    }

    @Test("Syscall is Equatable")
    func isEquatable() {
        let a = Kernel.File.Direct.Error.Syscall.notSupported(operation: .open)
        let b = Kernel.File.Direct.Error.Syscall.notSupported(operation: .open)
        let c = Kernel.File.Direct.Error.Syscall.notSupported(operation: .read)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Associated Value Tests

extension Kernel.File.Direct.Error.Syscall.Test.Unit {
    @Test("platform stores error code")
    func platformStoresCode() {
        let syscall = Kernel.File.Direct.Error.Syscall.platform(code: .posix(42), operation: .open)
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
        let syscall = Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .write)
        if case .platform(_, let operation) = syscall {
            if case .write = operation {
                // Expected
            } else {
                Issue.record("Expected .write operation")
            }
        } else {
            Issue.record("Expected .platform case")
        }
    }

    @Test("invalidDescriptor stores operation")
    func invalidDescriptorStoresOperation() {
        let syscall = Kernel.File.Direct.Error.Syscall.invalidDescriptor(operation: .read)
        if case .invalidDescriptor(let operation) = syscall {
            if case .read = operation {
                // Expected
            } else {
                Issue.record("Expected .read operation")
            }
        } else {
            Issue.record("Expected .invalidDescriptor case")
        }
    }

    @Test("alignmentViolation stores operation")
    func alignmentViolationStoresOperation() {
        let syscall = Kernel.File.Direct.Error.Syscall.alignmentViolation(operation: .write)
        if case .alignmentViolation(let operation) = syscall {
            if case .write = operation {
                // Expected
            } else {
                Issue.record("Expected .write operation")
            }
        } else {
            Issue.record("Expected .alignmentViolation case")
        }
    }

    @Test("notSupported stores operation")
    func notSupportedStoresOperation() {
        let syscall = Kernel.File.Direct.Error.Syscall.notSupported(operation: .open)
        if case .notSupported(let operation) = syscall {
            if case .open = operation {
                // Expected
            } else {
                Issue.record("Expected .open operation")
            }
        } else {
            Issue.record("Expected .notSupported case")
        }
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Error.Syscall.Test.EdgeCase {
    @Test("different cases with same operation are distinct")
    func differentCasesDistinct() {
        let invalidDesc = Kernel.File.Direct.Error.Syscall.invalidDescriptor(operation: .read)
        let alignment = Kernel.File.Direct.Error.Syscall.alignmentViolation(operation: .read)
        let notSupp = Kernel.File.Direct.Error.Syscall.notSupported(operation: .read)
        #expect(invalidDesc != alignment)
        #expect(alignment != notSupp)
        #expect(invalidDesc != notSupp)
    }

    @Test("platform errors with different codes are distinct")
    func platformCodesDistinct() {
        let error1 = Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .open)
        let error2 = Kernel.File.Direct.Error.Syscall.platform(code: .posix(2), operation: .open)
        #expect(error1 != error2)
    }

    @Test("platform errors with different operations are distinct")
    func platformOperationsDistinct() {
        let error1 = Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .read)
        let error2 = Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .write)
        #expect(error1 != error2)
    }
}
