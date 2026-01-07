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

extension Kernel.Error.Unmapped.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Error.Unmapped.Error.Test.Unit {
    @Test("Error type exists")
    func typeExists() {
        let _: Kernel.Error.Unmapped.Error.Type = Kernel.Error.Unmapped.Error.self
    }

    @Test("unmapped case exists")
    func unmappedCase() {
        let code = Kernel.Error.Code.posix(42)
        let error = Kernel.Error.Unmapped.Error.unmapped(code: code, message: nil)
        if case .unmapped(let c, let m) = error {
            #expect(c == code)
            #expect(m == nil)
        } else {
            Issue.record("Expected .unmapped case")
        }
    }

    @Test("unmapped case with message")
    func unmappedCaseWithMessage() {
        let code = Kernel.Error.Code.posix(42)
        let error = Kernel.Error.Unmapped.Error.unmapped(code: code, message: "test message")
        if case .unmapped(let c, let m) = error {
            #expect(c == code)
            #expect(m == "test message")
        } else {
            Issue.record("Expected .unmapped case")
        }
    }
}

// MARK: - Convenience Init Tests

extension Kernel.Error.Unmapped.Error.Test.Unit {
    @Test("convenience init from Error.Code")
    func convenienceInit() {
        let code = Kernel.Error.Code.posix(99)
        let error = Kernel.Error.Unmapped.Error(code)
        if case .unmapped(let c, let m) = error {
            #expect(c == code)
            #expect(m == nil)
        } else {
            Issue.record("Expected .unmapped case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Error.Unmapped.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isError() {
        let error: any Swift.Error = Kernel.Error.Unmapped.Error(.posix(1))
        #expect(error is Kernel.Error.Unmapped.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let value: any Sendable = Kernel.Error.Unmapped.Error(.posix(1))
        #expect(value is Kernel.Error.Unmapped.Error)
    }

    @Test("Error is Hashable")
    func isHashable() {
        var set = Set<Kernel.Error.Unmapped.Error>()
        set.insert(Kernel.Error.Unmapped.Error(.posix(1)))
        set.insert(Kernel.Error.Unmapped.Error(.posix(2)))
        set.insert(Kernel.Error.Unmapped.Error(.posix(1)))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Description Tests

extension Kernel.Error.Unmapped.Error.Test.Unit {
    @Test("description uses message if provided")
    func descriptionWithMessage() {
        let error = Kernel.Error.Unmapped.Error.unmapped(
            code: .posix(42),
            message: "custom message"
        )
        #expect(error.description == "custom message")
    }

    @Test("description fallback for no message")
    func descriptionWithoutMessage() {
        let error = Kernel.Error.Unmapped.Error(.posix(999))
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Edge Cases

extension Kernel.Error.Unmapped.Error.Test.EdgeCase {
    @Test("POSIX error code")
    func posixErrorCode() {
        let error = Kernel.Error.Unmapped.Error(.posix(42))
        if case .unmapped(let code, _) = error {
            if case .posix(let value) = code {
                #expect(value == 42)
            } else {
                Issue.record("Expected .posix code")
            }
        }
    }

    #if os(Windows)
        @Test("Windows error code")
        func windowsErrorCode() {
            let error = Kernel.Error.Unmapped.Error(.win32(5))
            if case .unmapped(let code, _) = error {
                if case .win32(let value) = code {
                    #expect(value == 5)
                } else {
                    Issue.record("Expected .win32 code")
                }
            }
        }
    #endif
}
