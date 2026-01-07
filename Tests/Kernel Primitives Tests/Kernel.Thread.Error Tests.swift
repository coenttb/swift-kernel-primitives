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

extension Kernel.Thread.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Thread.Error.Test.Unit {
    @Test("create case exists")
    func createCase() {
        let code = Kernel.Error.Code.posix(1)
        let error = Kernel.Thread.Error.create(code)
        if case .create(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .create case")
        }
    }

    @Test("join case exists")
    func joinCase() {
        let code = Kernel.Error.Code.posix(2)
        let error = Kernel.Thread.Error.join(code)
        if case .join(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .join case")
        }
    }

    @Test("detach case exists")
    func detachCase() {
        let code = Kernel.Error.Code.posix(3)
        let error = Kernel.Thread.Error.detach(code)
        if case .detach(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .detach case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.Thread.Error.Test.Unit {
    @Test("create description contains 'Thread creation failed'")
    func createDescription() {
        let error = Kernel.Thread.Error.create(.posix(1))
        #expect(error.description.contains("Thread creation failed"))
    }

    @Test("join description contains 'Thread join failed'")
    func joinDescription() {
        let error = Kernel.Thread.Error.join(.posix(1))
        #expect(error.description.contains("Thread join failed"))
    }

    @Test("detach description contains 'Thread detach failed'")
    func detachDescription() {
        let error = Kernel.Thread.Error.detach(.posix(1))
        #expect(error.description.contains("Thread detach failed"))
    }
}

// MARK: - Conformance Tests

extension Kernel.Thread.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.Thread.Error.create(.posix(1))
        #expect(error is Kernel.Thread.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.Thread.Error.create(.posix(1))
        #expect(error is Kernel.Thread.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.Thread.Error.create(.posix(1))
        let b = Kernel.Thread.Error.create(.posix(1))
        let c = Kernel.Thread.Error.join(.posix(1))
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Error is Hashable")
    func isHashable() {
        var set = Set<Kernel.Thread.Error>()
        set.insert(.create(.posix(1)))
        set.insert(.join(.posix(2)))
        set.insert(.detach(.posix(3)))
        set.insert(.create(.posix(1)))  // duplicate
        #expect(set.count == 3)
    }

    @Test("Error is CustomStringConvertible")
    func isCustomStringConvertible() {
        let error: any CustomStringConvertible = Kernel.Thread.Error.create(.posix(1))
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Edge Cases

extension Kernel.Thread.Error.Test.EdgeCase {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let code = Kernel.Error.Code.posix(1)
        let cases: [Kernel.Thread.Error] = [
            .create(code),
            .join(code),
            .detach(code),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("same case with different codes are distinct")
    func differentCodesDistinct() {
        let a = Kernel.Thread.Error.create(.posix(1))
        let b = Kernel.Thread.Error.create(.posix(2))
        #expect(a != b)
    }

    @Test("all descriptions are non-empty")
    func allDescriptionsNonEmpty() {
        let code = Kernel.Error.Code.posix(1)
        let cases: [Kernel.Thread.Error] = [
            .create(code),
            .join(code),
            .detach(code),
        ]

        for error in cases {
            #expect(!error.description.isEmpty)
        }
    }

    #if os(Windows)
        @Test("win32 error code")
        func win32ErrorCode() {
            let error = Kernel.Thread.Error.create(.win32(5))
            if case .create(let code) = error {
                if case .win32(let value) = code {
                    #expect(value == 5)
                } else {
                    Issue.record("Expected .win32 code")
                }
            } else {
                Issue.record("Expected .create case")
            }
        }
    #endif
}
