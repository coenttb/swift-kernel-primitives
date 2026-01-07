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

import Binary
import StandardsTestSupport
import Testing

@testable import Kernel_Primitives

extension Kernel.File.Direct.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Error.Test.Unit {
    @Test("notSupported case exists")
    func notSupportedCase() {
        let error = Kernel.File.Direct.Error.notSupported
        if case .notSupported = error {
            // Expected
        } else {
            Issue.record("Expected .notSupported case")
        }
    }

    @Test("misalignedBuffer case exists")
    func misalignedBufferCase() {
        let error = Kernel.File.Direct.Error.misalignedBuffer(address: 123, required: .`4096`)
        if case .misalignedBuffer = error {
            // Expected
        } else {
            Issue.record("Expected .misalignedBuffer case")
        }
    }

    @Test("misalignedOffset case exists")
    func misalignedOffsetCase() {
        let error = Kernel.File.Direct.Error.misalignedOffset(offset: 100, required: .`4096`)
        if case .misalignedOffset = error {
            // Expected
        } else {
            Issue.record("Expected .misalignedOffset case")
        }
    }

    @Test("invalidLength case exists")
    func invalidLengthCase() {
        let error = Kernel.File.Direct.Error.invalidLength(length: 1000, requiredMultiple: .`4096`)
        if case .invalidLength = error {
            // Expected
        } else {
            Issue.record("Expected .invalidLength case")
        }
    }

    @Test("modeChange case exists")
    func modeChangeCase() {
        let error = Kernel.File.Direct.Error.modeChange
        if case .modeChange = error {
            // Expected
        } else {
            Issue.record("Expected .modeChange case")
        }
    }

    @Test("invalidHandle case exists")
    func invalidHandleCase() {
        let error = Kernel.File.Direct.Error.invalidHandle
        if case .invalidHandle = error {
            // Expected
        } else {
            Issue.record("Expected .invalidHandle case")
        }
    }

    @Test("platform case exists")
    func platformCase() {
        let error = Kernel.File.Direct.Error.platform(code: .posix(1), operation: .open)
        if case .platform = error {
            // Expected
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.File.Direct.Error.Test.Unit {
    @Test("notSupported description")
    func notSupportedDescription() {
        let error = Kernel.File.Direct.Error.notSupported
        #expect(error.description == "Direct I/O not supported")
    }

    @Test("modeChange description")
    func modeChangeDescription() {
        let error = Kernel.File.Direct.Error.modeChange
        #expect(error.description == "Failed to change cache mode")
    }

    @Test("invalidHandle description")
    func invalidHandleDescription() {
        let error = Kernel.File.Direct.Error.invalidHandle
        #expect(error.description == "Invalid file handle")
    }

    @Test("misalignedBuffer description includes address")
    func misalignedBufferDescription() {
        let error = Kernel.File.Direct.Error.misalignedBuffer(address: 123, required: .`4096`)
        #expect(error.description.contains("Buffer address"))
        #expect(error.description.contains("4096"))
    }

    @Test("misalignedOffset description includes offset")
    func misalignedOffsetDescription() {
        let error = Kernel.File.Direct.Error.misalignedOffset(offset: 100, required: .`4096`)
        #expect(error.description.contains("File offset"))
        #expect(error.description.contains("100"))
    }

    @Test("invalidLength description includes length")
    func invalidLengthDescription() {
        let error = Kernel.File.Direct.Error.invalidLength(length: 1000, requiredMultiple: .`4096`)
        #expect(error.description.contains("Length"))
        #expect(error.description.contains("1000"))
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.File.Direct.Error.notSupported
        #expect(error is Kernel.File.Direct.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.File.Direct.Error.notSupported
        #expect(error is Kernel.File.Direct.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.File.Direct.Error.notSupported
        let b = Kernel.File.Direct.Error.notSupported
        let c = Kernel.File.Direct.Error.modeChange
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Nested Types

extension Kernel.File.Direct.Error.Test.Unit {
    @Test("Operation type exists")
    func operationTypeExists() {
        let _: Kernel.File.Direct.Error.Operation.Type = Kernel.File.Direct.Error.Operation.self
    }

    @Test("Syscall type exists")
    func syscallTypeExists() {
        let _: Kernel.File.Direct.Error.Syscall.Type = Kernel.File.Direct.Error.Syscall.self
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Error.Test.EdgeCase {
    @Test("all simple cases are distinct")
    func simpleCasesDistinct() {
        let cases: [Kernel.File.Direct.Error] = [
            .notSupported,
            .modeChange,
            .invalidHandle,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("misalignedBuffer errors with different addresses are distinct")
    func misalignedBufferDistinct() {
        let error1 = Kernel.File.Direct.Error.misalignedBuffer(address: 100, required: .`4096`)
        let error2 = Kernel.File.Direct.Error.misalignedBuffer(address: 200, required: .`4096`)
        #expect(error1 != error2)
    }

    @Test("all descriptions are non-empty")
    func allDescriptionsNonEmpty() {
        let cases: [Kernel.File.Direct.Error] = [
            .notSupported,
            .misalignedBuffer(address: 123, required: .`4096`),
            .misalignedOffset(offset: 100, required: .`4096`),
            .invalidLength(length: 1000, requiredMultiple: .`4096`),
            .modeChange,
            .invalidHandle,
            .platform(code: .posix(1), operation: .open),
        ]

        for error in cases {
            #expect(!error.description.isEmpty)
        }
    }
}
