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

extension Kernel.Memory.Map.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Memory.Map.Error.Test.Unit {
    @Test("map case stores Error.Code")
    func mapCase() {
        let code = Kernel.Error.Code.posix(22)
        let error = Kernel.Memory.Map.Error.map(code)
        if case .map(let stored) = error {
            #expect(stored == code)
        } else {
            Issue.record("Expected .map case")
        }
    }

    @Test("unmap case stores Error.Code")
    func unmapCase() {
        let code = Kernel.Error.Code.posix(22)
        let error = Kernel.Memory.Map.Error.unmap(code)
        if case .unmap(let stored) = error {
            #expect(stored == code)
        } else {
            Issue.record("Expected .unmap case")
        }
    }

    @Test("sync case stores Error.Code")
    func syncCase() {
        let code = Kernel.Error.Code.posix(22)
        let error = Kernel.Memory.Map.Error.sync(code)
        if case .sync(let stored) = error {
            #expect(stored == code)
        } else {
            Issue.record("Expected .sync case")
        }
    }

    @Test("protect case stores Error.Code")
    func protectCase() {
        let code = Kernel.Error.Code.posix(22)
        let error = Kernel.Memory.Map.Error.protect(code)
        if case .protect(let stored) = error {
            #expect(stored == code)
        } else {
            Issue.record("Expected .protect case")
        }
    }

    @Test("invalid case stores Validation")
    func invalidCase() {
        let error = Kernel.Memory.Map.Error.invalid(.length)
        if case .invalid(.length) = error {
            // Expected
        } else {
            Issue.record("Expected .invalid(.length) case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.Memory.Map.Error.Test.Unit {
    @Test("map description format")
    func mapDescription() {
        let error = Kernel.Memory.Map.Error.map(.posix(22))
        #expect(error.description.contains("mmap failed"))
    }

    @Test("unmap description format")
    func unmapDescription() {
        let error = Kernel.Memory.Map.Error.unmap(.posix(22))
        #expect(error.description.contains("munmap failed"))
    }

    @Test("sync description format")
    func syncDescription() {
        let error = Kernel.Memory.Map.Error.sync(.posix(22))
        #expect(error.description.contains("msync failed"))
    }

    @Test("protect description format")
    func protectDescription() {
        let error = Kernel.Memory.Map.Error.protect(.posix(22))
        #expect(error.description.contains("mprotect failed"))
    }

    @Test("invalid description format")
    func invalidDescription() {
        let error = Kernel.Memory.Map.Error.invalid(.length)
        #expect(error.description.contains("invalid argument"))
    }
}

// MARK: - Conformance Tests

extension Kernel.Memory.Map.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.Memory.Map.Error.map(.posix(1))
        #expect(error is Kernel.Memory.Map.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.Memory.Map.Error.map(.posix(1))
        #expect(error is Kernel.Memory.Map.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.Memory.Map.Error.map(.posix(1))
        let b = Kernel.Memory.Map.Error.map(.posix(1))
        let c = Kernel.Memory.Map.Error.map(.posix(2))
        let d = Kernel.Memory.Map.Error.unmap(.posix(1))
        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
    }

    @Test("Error is Hashable")
    func isHashable() {
        var set = Set<Kernel.Memory.Map.Error>()
        set.insert(.map(.posix(1)))
        set.insert(.unmap(.posix(1)))
        set.insert(.map(.posix(1)))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Memory.Map.Error.Test.EdgeCase {
    @Test("all operation cases are distinct")
    func operationCasesDistinct() {
        let code = Kernel.Error.Code.posix(22)
        let cases: [Kernel.Memory.Map.Error] = [
            .map(code),
            .unmap(code),
            .sync(code),
            .protect(code),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("validation cases are distinct")
    func validationCasesDistinct() {
        let length = Kernel.Memory.Map.Error.invalid(.length)
        let alignment = Kernel.Memory.Map.Error.invalid(.alignment)
        let offset = Kernel.Memory.Map.Error.invalid(.offset)
        #expect(length != alignment)
        #expect(alignment != offset)
        #expect(length != offset)
    }
}
