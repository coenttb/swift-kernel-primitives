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

extension Kernel.IO.Read.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.IO.Read.Error.Test.Unit {
    @Test("handle case stores Descriptor.Validity.Error")
    func handleCase() {
        let validityError = Kernel.Descriptor.Validity.Error.invalid
        let error = Kernel.IO.Read.Error.handle(validityError)
        if case .handle(let stored) = error {
            #expect(stored == validityError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test("blocking case stores IO.Blocking.Error")
    func blockingCase() {
        let blockingError = Kernel.IO.Blocking.Error.wouldBlock
        let error = Kernel.IO.Read.Error.blocking(blockingError)
        if case .blocking(let stored) = error {
            #expect(stored == blockingError)
        } else {
            Issue.record("Expected .blocking case")
        }
    }

    @Test("io case stores IO.Error")
    func ioCase() {
        let ioError = Kernel.IO.Error.broken
        let error = Kernel.IO.Read.Error.io(ioError)
        if case .io(let stored) = error {
            #expect(stored == ioError)
        } else {
            Issue.record("Expected .io case")
        }
    }

    @Test("memory case stores Memory.Error")
    func memoryCase() {
        let memoryError = Kernel.Memory.Error.fault
        let error = Kernel.IO.Read.Error.memory(memoryError)
        if case .memory(let stored) = error {
            #expect(stored == memoryError)
        } else {
            Issue.record("Expected .memory case")
        }
    }

    @Test("platform case stores Errno.Unmapped.Error")
    func platformCase() {
        let code = Kernel.Error.Code.posix(999)
        let unmappedError = Kernel.Error.Unmapped.Error.unmapped(code: code, message: nil)
        let error = Kernel.IO.Read.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.IO.Read.Error.Test.Unit {
    @Test("handle description format")
    func handleDescription() {
        let error = Kernel.IO.Read.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

    @Test("blocking description format")
    func blockingDescription() {
        let error = Kernel.IO.Read.Error.blocking(.wouldBlock)
        #expect(error.description.contains("blocking:"))
    }

    @Test("io description format")
    func ioDescription() {
        let error = Kernel.IO.Read.Error.io(.broken)
        #expect(error.description.contains("io:"))
    }

    @Test("memory description format")
    func memoryDescription() {
        let error = Kernel.IO.Read.Error.memory(.fault)
        #expect(error.description.contains("memory:"))
    }
}

// MARK: - Conformance Tests

extension Kernel.IO.Read.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.IO.Read.Error.handle(.invalid)
        #expect(error is Kernel.IO.Read.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.IO.Read.Error.handle(.invalid)
        #expect(error is Kernel.IO.Read.Error)
    }

    @Test("Error is Equatable - same case same value")
    func isEquatableSame() {
        let a = Kernel.IO.Read.Error.io(.broken)
        let b = Kernel.IO.Read.Error.io(.broken)
        #expect(a == b)
    }

    @Test("Error is Equatable - same case different value")
    func isEquatableDifferentValue() {
        let a = Kernel.IO.Read.Error.io(.broken)
        let b = Kernel.IO.Read.Error.io(.reset)
        #expect(a != b)
    }

    @Test("Error is Equatable - different cases")
    func isEquatableDifferentCase() {
        let a = Kernel.IO.Read.Error.handle(.invalid)
        let b = Kernel.IO.Read.Error.memory(.fault)
        #expect(a != b)
    }
}

// MARK: - Edge Cases

extension Kernel.IO.Read.Error.Test.EdgeCase {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.IO.Read.Error] = [
            .handle(.invalid),
            .blocking(.wouldBlock),
            .io(.broken),
            .memory(.fault),
            .platform(.unmapped(code: .posix(1), message: nil)),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("memory fault vs exhausted")
    func memoryFaultVsExhausted() {
        let fault = Kernel.IO.Read.Error.memory(.fault)
        let exhausted = Kernel.IO.Read.Error.memory(.exhausted)
        #expect(fault != exhausted)
    }
}
