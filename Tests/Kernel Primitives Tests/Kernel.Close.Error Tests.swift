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

extension Kernel.Close.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Close.Error.Test.Unit {
    @Test("handle case stores Descriptor.Validity.Error")
    func handleCase() {
        let validityError = Kernel.Descriptor.Validity.Error.invalid
        let error = Kernel.Close.Error.handle(validityError)
        if case .handle(let stored) = error {
            #expect(stored == validityError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test("io case stores IO.Error")
    func ioCase() {
        let ioError = Kernel.IO.Error.broken
        let error = Kernel.Close.Error.io(ioError)
        if case .io(let stored) = error {
            #expect(stored == ioError)
        } else {
            Issue.record("Expected .io case")
        }
    }

    @Test("platform case stores Kernel.Error")
    func platformCase() {
        let code = Kernel.Error.Code.posix(999)
        let platformError = Kernel.Error(code: code)
        let error = Kernel.Close.Error.platform(platformError)
        if case .platform(let stored) = error {
            #expect(stored == platformError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.Close.Error.Test.Unit {
    @Test("handle description format")
    func handleDescription() {
        let error = Kernel.Close.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

    @Test("io description format")
    func ioDescription() {
        let error = Kernel.Close.Error.io(.broken)
        #expect(error.description.contains("io:"))
    }
}

// MARK: - Conformance Tests

extension Kernel.Close.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.Close.Error.handle(.invalid)
        #expect(error is Kernel.Close.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.Close.Error.handle(.invalid)
        #expect(error is Kernel.Close.Error)
    }

    @Test("Error is Equatable - same case same value")
    func isEquatableSame() {
        let a = Kernel.Close.Error.handle(.invalid)
        let b = Kernel.Close.Error.handle(.invalid)
        #expect(a == b)
    }

    @Test("Error is Equatable - same case different value")
    func isEquatableDifferentValue() {
        let a = Kernel.Close.Error.handle(.invalid)
        let b = Kernel.Close.Error.handle(.limit(.process))
        #expect(a != b)
    }

    @Test("Error is Equatable - different cases")
    func isEquatableDifferentCase() {
        let a = Kernel.Close.Error.handle(.invalid)
        let b = Kernel.Close.Error.io(.broken)
        #expect(a != b)
    }
}

// MARK: - Edge Cases

extension Kernel.Close.Error.Test.EdgeCase {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.Close.Error] = [
            .handle(.invalid),
            .io(.broken),
            .platform(Kernel.Error(code: .posix(1))),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("handle with process limit")
    func handleProcessLimit() {
        let error = Kernel.Close.Error.handle(.limit(.process))
        if case .handle(.limit(.process)) = error {
            // Expected
        } else {
            Issue.record("Expected .handle(.limit(.process))")
        }
    }

    @Test("handle with system limit")
    func handleSystemLimit() {
        let error = Kernel.Close.Error.handle(.limit(.system))
        if case .handle(.limit(.system)) = error {
            // Expected
        } else {
            Issue.record("Expected .handle(.limit(.system))")
        }
    }
}
