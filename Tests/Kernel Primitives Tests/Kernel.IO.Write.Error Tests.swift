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

extension Kernel.IO.Write.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.IO.Write.Error.Test.Unit {
    @Test("handle case stores Descriptor.Validity.Error")
    func handleCase() {
        let validityError = Kernel.Descriptor.Validity.Error.invalid
        let error = Kernel.IO.Write.Error.handle(validityError)
        if case .handle(let stored) = error {
            #expect(stored == validityError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test("blocking case stores IO.Blocking.Error")
    func blockingCase() {
        let blockingError = Kernel.IO.Blocking.Error.wouldBlock
        let error = Kernel.IO.Write.Error.blocking(blockingError)
        if case .blocking(let stored) = error {
            #expect(stored == blockingError)
        } else {
            Issue.record("Expected .blocking case")
        }
    }

    @Test("io case stores IO.Error")
    func ioCase() {
        let ioError = Kernel.IO.Error.broken
        let error = Kernel.IO.Write.Error.io(ioError)
        if case .io(let stored) = error {
            #expect(stored == ioError)
        } else {
            Issue.record("Expected .io case")
        }
    }

    @Test("space case stores Storage.Error")
    func spaceCase() {
        let spaceError = Kernel.Storage.Error.exhausted
        let error = Kernel.IO.Write.Error.space(spaceError)
        if case .space(let stored) = error {
            #expect(stored == spaceError)
        } else {
            Issue.record("Expected .space case")
        }
    }

    @Test("memory case stores Memory.Error")
    func memoryCase() {
        let memoryError = Kernel.Memory.Error.fault
        let error = Kernel.IO.Write.Error.memory(memoryError)
        if case .memory(let stored) = error {
            #expect(stored == memoryError)
        } else {
            Issue.record("Expected .memory case")
        }
    }

    @Test("platform case stores Kernel.Error")
    func platformCase() {
        let code = Kernel.Error.Code.posix(999)
        let unmappedError = Kernel.Error(code: code)
        let error = Kernel.IO.Write.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.IO.Write.Error.Test.Unit {
    @Test("handle description format")
    func handleDescription() {
        let error = Kernel.IO.Write.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

    @Test("blocking description format")
    func blockingDescription() {
        let error = Kernel.IO.Write.Error.blocking(.wouldBlock)
        #expect(error.description.contains("blocking:"))
    }

    @Test("io description format")
    func ioDescription() {
        let error = Kernel.IO.Write.Error.io(.broken)
        #expect(error.description.contains("io:"))
    }

    @Test("space description format")
    func spaceDescription() {
        let error = Kernel.IO.Write.Error.space(.exhausted)
        #expect(error.description.contains("space:"))
    }

    @Test("memory description format")
    func memoryDescription() {
        let error = Kernel.IO.Write.Error.memory(.fault)
        #expect(error.description.contains("memory:"))
    }
}

// MARK: - Conformance Tests

extension Kernel.IO.Write.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.IO.Write.Error.handle(.invalid)
        #expect(error is Kernel.IO.Write.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.IO.Write.Error.handle(.invalid)
        #expect(error is Kernel.IO.Write.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.IO.Write.Error.space(.exhausted)
        let b = Kernel.IO.Write.Error.space(.exhausted)
        let c = Kernel.IO.Write.Error.space(.quota)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.IO.Write.Error.Test.EdgeCase {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.IO.Write.Error] = [
            .handle(.invalid),
            .blocking(.wouldBlock),
            .io(.broken),
            .space(.exhausted),
            .memory(.fault),
            .platform(Kernel.Error(code: .posix(1))),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("space exhausted vs quota")
    func spaceExhaustedVsQuota() {
        let exhausted = Kernel.IO.Write.Error.space(.exhausted)
        let quota = Kernel.IO.Write.Error.space(.quota)
        #expect(exhausted != quota)
    }

    @Test("Write has space case that Read lacks")
    func writeHasSpaceCase() {
        // Verify the space case exists (unique to Write.Error vs Read.Error)
        let error = Kernel.IO.Write.Error.space(.exhausted)
        if case .space = error {
            // Expected - this case exists
        } else {
            Issue.record("Expected .space case")
        }
    }
}
