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

extension Kernel.File.Handle.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Handle.Error.Test.Unit {
    @Test("invalidHandle case exists")
    func invalidHandleCase() {
        let error = Kernel.File.Handle.Error.invalidHandle
        if case .invalidHandle = error {
            // Expected
        } else {
            Issue.record("Expected .invalidHandle case")
        }
    }

    @Test("endOfFile case exists")
    func endOfFileCase() {
        let error = Kernel.File.Handle.Error.endOfFile
        if case .endOfFile = error {
            // Expected
        } else {
            Issue.record("Expected .endOfFile case")
        }
    }

    @Test("interrupted case exists")
    func interruptedCase() {
        let error = Kernel.File.Handle.Error.interrupted
        if case .interrupted = error {
            // Expected
        } else {
            Issue.record("Expected .interrupted case")
        }
    }

    @Test("noSpace case exists")
    func noSpaceCase() {
        let error = Kernel.File.Handle.Error.noSpace
        if case .noSpace = error {
            // Expected
        } else {
            Issue.record("Expected .noSpace case")
        }
    }

    @Test("misalignedBuffer case stores address and alignment")
    func misalignedBufferCase() {
        let error = Kernel.File.Handle.Error.misalignedBuffer(address: 0x1234, required: .`512`)
        if case .misalignedBuffer(let addr, let req) = error {
            #expect(addr == 0x1234)
            #expect(req == .`512`)
        } else {
            Issue.record("Expected .misalignedBuffer case")
        }
    }

    @Test("misalignedOffset case stores offset and alignment")
    func misalignedOffsetCase() {
        let error = Kernel.File.Handle.Error.misalignedOffset(offset: 1000, required: .`512`)
        if case .misalignedOffset(let off, let req) = error {
            #expect(off == 1000)
            #expect(req == .`512`)
        } else {
            Issue.record("Expected .misalignedOffset case")
        }
    }

    @Test("invalidLength case stores length and required multiple")
    func invalidLengthCase() {
        let error = Kernel.File.Handle.Error.invalidLength(length: 100, requiredMultiple: .`512`)
        if case .invalidLength(let len, let req) = error {
            #expect(len == 100)
            #expect(req == .`512`)
        } else {
            Issue.record("Expected .invalidLength case")
        }
    }

    @Test("requirementsUnknown case exists")
    func requirementsUnknownCase() {
        let error = Kernel.File.Handle.Error.requirementsUnknown
        if case .requirementsUnknown = error {
            // Expected
        } else {
            Issue.record("Expected .requirementsUnknown case")
        }
    }

    @Test("alignmentViolation case stores operation")
    func alignmentViolationCase() {
        let error = Kernel.File.Handle.Error.alignmentViolation(operation: .read)
        if case .alignmentViolation(let op) = error {
            #expect(op == .read)
        } else {
            Issue.record("Expected .alignmentViolation case")
        }
    }

    @Test("platform case stores code and operation")
    func platformCase() {
        let code = Kernel.Error.Code.posix(22)
        let error = Kernel.File.Handle.Error.platform(code: code, operation: .write)
        if case .platform(let storedCode, let op) = error {
            #expect(storedCode == code)
            #expect(op == .write)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.File.Handle.Error.Test.Unit {
    @Test("invalidHandle description")
    func invalidHandleDescription() {
        #expect(Kernel.File.Handle.Error.invalidHandle.description == "Invalid file handle")
    }

    @Test("endOfFile description")
    func endOfFileDescription() {
        #expect(Kernel.File.Handle.Error.endOfFile.description == "End of file")
    }

    @Test("interrupted description")
    func interruptedDescription() {
        #expect(Kernel.File.Handle.Error.interrupted.description == "Operation interrupted")
    }

    @Test("noSpace description")
    func noSpaceDescription() {
        #expect(Kernel.File.Handle.Error.noSpace.description == "No space left on device")
    }

    @Test("misalignedBuffer description contains address")
    func misalignedBufferDescription() {
        let error = Kernel.File.Handle.Error.misalignedBuffer(address: 0x1234, required: .`512`)
        #expect(error.description.contains("Buffer address"))
        #expect(error.description.contains("not aligned"))
    }

    @Test("misalignedOffset description contains offset")
    func misalignedOffsetDescription() {
        let error = Kernel.File.Handle.Error.misalignedOffset(offset: 1000, required: .`512`)
        #expect(error.description.contains("File offset"))
        #expect(error.description.contains("1000"))
    }

    @Test("invalidLength description contains length")
    func invalidLengthDescription() {
        let error = Kernel.File.Handle.Error.invalidLength(length: 100, requiredMultiple: .`512`)
        #expect(error.description.contains("Length"))
        #expect(error.description.contains("100"))
    }

    @Test("requirementsUnknown description")
    func requirementsUnknownDescription() {
        #expect(Kernel.File.Handle.Error.requirementsUnknown.description == "Direct I/O requirements unknown")
    }

    @Test("alignmentViolation description contains operation")
    func alignmentViolationDescription() {
        let error = Kernel.File.Handle.Error.alignmentViolation(operation: .read)
        #expect(error.description.contains("Alignment violation"))
        #expect(error.description.contains("read"))
    }

    @Test("platform description contains operation")
    func platformDescription() {
        let error = Kernel.File.Handle.Error.platform(code: .posix(22), operation: .write)
        #expect(error.description.contains("write"))
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Handle.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.File.Handle.Error.invalidHandle
        #expect(error is Kernel.File.Handle.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.File.Handle.Error.invalidHandle
        #expect(error is Kernel.File.Handle.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.File.Handle.Error.invalidHandle
        let b = Kernel.File.Handle.Error.invalidHandle
        let c = Kernel.File.Handle.Error.endOfFile
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Operation Enum Tests

extension Kernel.File.Handle.Error.Test.Unit {
    @Test("Operation read case")
    func operationRead() {
        let op = Kernel.File.Handle.Operation.read
        #expect(op.rawValue == "read")
    }

    @Test("Operation write case")
    func operationWrite() {
        let op = Kernel.File.Handle.Operation.write
        #expect(op.rawValue == "write")
    }

    @Test("Operation seek case")
    func operationSeek() {
        let op = Kernel.File.Handle.Operation.seek
        #expect(op.rawValue == "seek")
    }

    @Test("Operation sync case")
    func operationSync() {
        let op = Kernel.File.Handle.Operation.sync
        #expect(op.rawValue == "sync")
    }
}

// MARK: - Edge Cases

extension Kernel.File.Handle.Error.Test.EdgeCase {
    @Test("simple cases are distinct")
    func simpleCasesDistinct() {
        let cases: [Kernel.File.Handle.Error] = [
            .invalidHandle,
            .endOfFile,
            .interrupted,
            .noSpace,
            .requirementsUnknown,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("different operations are distinct in alignmentViolation")
    func alignmentViolationOperationsDistinct() {
        let read = Kernel.File.Handle.Error.alignmentViolation(operation: .read)
        let write = Kernel.File.Handle.Error.alignmentViolation(operation: .write)
        let seek = Kernel.File.Handle.Error.alignmentViolation(operation: .seek)
        #expect(read != write)
        #expect(write != seek)
    }

    @Test("different addresses in misalignedBuffer are distinct")
    func misalignedBufferAddressesDistinct() {
        let a = Kernel.File.Handle.Error.misalignedBuffer(address: 100, required: .`512`)
        let b = Kernel.File.Handle.Error.misalignedBuffer(address: 200, required: .`512`)
        #expect(a != b)
    }

    @Test("different alignments in misalignedBuffer are distinct")
    func misalignedBufferAlignmentsDistinct() {
        let a = Kernel.File.Handle.Error.misalignedBuffer(address: 100, required: .`512`)
        let b = Kernel.File.Handle.Error.misalignedBuffer(address: 100, required: .`4096`)
        #expect(a != b)
    }
}
