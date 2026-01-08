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

extension Kernel.File.Stats.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Stats.Error.Test.Unit {
    @Test("handle case stores Descriptor.Validity.Error")
    func handleCase() {
        let handleError = Kernel.Descriptor.Validity.Error.invalid
        let error = Kernel.File.Stats.Error.handle(handleError)
        if case .handle(let stored) = error {
            #expect(stored == handleError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test("io case stores IO.Error")
    func ioCase() {
        let ioError = Kernel.IO.Error.hardware
        let error = Kernel.File.Stats.Error.io(ioError)
        if case .io(let stored) = error {
            #expect(stored == ioError)
        } else {
            Issue.record("Expected .io case")
        }
    }

    @Test("platform case stores Kernel.Error")
    func platformCase() {
        let code = Kernel.Error.Code.posix(999)
        let unmappedError = Kernel.Error(code: code)
        let error = Kernel.File.Stats.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.File.Stats.Error.Test.Unit {
    @Test("handle description format")
    func handleDescription() {
        let error = Kernel.File.Stats.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

    @Test("io description format")
    func ioDescription() {
        let error = Kernel.File.Stats.Error.io(.hardware)
        #expect(error.description.contains("io:"))
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Stats.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.File.Stats.Error.handle(.invalid)
        #expect(error is Kernel.File.Stats.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.File.Stats.Error.handle(.invalid)
        #expect(error is Kernel.File.Stats.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.File.Stats.Error.handle(.invalid)
        let b = Kernel.File.Stats.Error.handle(.invalid)
        let c = Kernel.File.Stats.Error.io(.hardware)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Stats.Error.Test.EdgeCase {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.File.Stats.Error] = [
            .handle(.invalid),
            .io(.hardware),
            .platform(Kernel.Error(code: .posix(1))),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("handle invalid vs limit are distinct")
    func handleCasesDistinct() {
        let invalid = Kernel.File.Stats.Error.handle(.invalid)
        let processLimit = Kernel.File.Stats.Error.handle(.limit(.process))
        let systemLimit = Kernel.File.Stats.Error.handle(.limit(.system))
        #expect(invalid != processLimit)
        #expect(processLimit != systemLimit)
    }

    @Test("different io errors are distinct")
    func ioErrorsDistinct() {
        let hardware = Kernel.File.Stats.Error.io(.hardware)
        let broken = Kernel.File.Stats.Error.io(.broken)
        #expect(hardware != broken)
    }
}
