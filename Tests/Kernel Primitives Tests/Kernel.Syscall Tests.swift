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

extension Kernel.Syscall {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Syscall.Test.Unit {
    @Test("Syscall namespace exists")
    func namespaceExists() {
        _ = Kernel.Syscall.self
    }

    @Test("Syscall is an enum")
    func isEnum() {
        let _: Kernel.Syscall.Type = Kernel.Syscall.self
    }

    @Test("Rule type exists")
    func ruleTypeExists() {
        let _: Kernel.Syscall.Rule<Int>.Type = Kernel.Syscall.Rule<Int>.self
    }
}

// MARK: - require Tests

extension Kernel.Syscall.Test.Unit {
    @Test("require with passing rule returns value")
    func requirePassing() throws {
        struct TestError: Error {}
        let result = try Kernel.Syscall.require(
            42,
            .equals(42),
            orThrow: TestError()
        )
        #expect(result == 42)
    }

    @Test("require with failing rule throws")
    func requireFailing() {
        struct TestError: Error {}
        #expect(throws: TestError.self) {
            try Kernel.Syscall.require(
                42,
                .equals(0),
                orThrow: TestError()
            )
        }
    }
}

// MARK: - Integer Rules Tests

extension Kernel.Syscall.Test.Unit {
    @Test("nonNegative rule passes for positive")
    func nonNegativePositive() throws {
        struct TestError: Error {}
        let result = try Kernel.Syscall.require(
            100,
            .nonNegative,
            orThrow: TestError()
        )
        #expect(result == 100)
    }

    @Test("nonNegative rule passes for zero")
    func nonNegativeZero() throws {
        struct TestError: Error {}
        let result = try Kernel.Syscall.require(
            0,
            .nonNegative,
            orThrow: TestError()
        )
        #expect(result == 0)
    }

    @Test("nonNegative rule fails for negative")
    func nonNegativeNegative() {
        struct TestError: Error {}
        #expect(throws: TestError.self) {
            try Kernel.Syscall.require(
                -1,
                .nonNegative,
                orThrow: TestError()
            )
        }
    }
}

// MARK: - Equatable Rules Tests

extension Kernel.Syscall.Test.Unit {
    @Test("equals rule passes for match")
    func equalsMatch() throws {
        struct TestError: Error {}
        let result = try Kernel.Syscall.require(
            "test",
            .equals("test"),
            orThrow: TestError()
        )
        #expect(result == "test")
    }

    @Test("equals rule fails for mismatch")
    func equalsMismatch() {
        struct TestError: Error {}
        #expect(throws: TestError.self) {
            try Kernel.Syscall.require(
                "test",
                .equals("other"),
                orThrow: TestError()
            )
        }
    }

    @Test("not rule passes for different value")
    func notDifferent() throws {
        struct TestError: Error {}
        let result = try Kernel.Syscall.require(
            42,
            .not(-1),
            orThrow: TestError()
        )
        #expect(result == 42)
    }

    @Test("not rule fails for same value")
    func notSame() {
        struct TestError: Error {}
        #expect(throws: TestError.self) {
            try Kernel.Syscall.require(
                -1,
                .not(-1),
                orThrow: TestError()
            )
        }
    }
}

// MARK: - Boolean Rules Tests

extension Kernel.Syscall.Test.Unit {
    @Test("isTrue rule passes for true")
    func isTrueForTrue() throws {
        struct TestError: Error {}
        let result = try Kernel.Syscall.require(
            true,
            .isTrue,
            orThrow: TestError()
        )
        #expect(result == true)
    }

    @Test("isTrue rule fails for false")
    func isTrueForFalse() {
        struct TestError: Error {}
        #expect(throws: TestError.self) {
            try Kernel.Syscall.require(
                false,
                .isTrue,
                orThrow: TestError()
            )
        }
    }
}

// MARK: - Optional Rules Tests

extension Kernel.Syscall.Test.Unit {
    @Test("notNil rule passes for some value")
    func notNilForSome() throws {
        struct TestError: Error {}
        let value: Int? = 42
        let result = try Kernel.Syscall.require(
            value,
            .notNil(),
            orThrow: TestError()
        )
        #expect(result == 42)
    }

    @Test("notNil rule fails for nil")
    func notNilForNil() {
        struct TestError: Error {}
        let value: Int? = nil
        #expect(throws: TestError.self) {
            try Kernel.Syscall.require(
                value,
                .notNil(),
                orThrow: TestError()
            )
        }
    }
}

// MARK: - Edge Cases

extension Kernel.Syscall.Test.EdgeCase {
    @Test("require is discardable")
    func discardableResult() throws {
        struct TestError: Error {}
        // No assignment - just testing that it compiles and doesn't warn
        try Kernel.Syscall.require(0, .equals(0), orThrow: TestError())
    }

    @Test("custom rule")
    func customRule() throws {
        struct TestError: Error {}
        let isEven = Kernel.Syscall.Rule<Int> { $0 % 2 == 0 }
        let result = try Kernel.Syscall.require(42, isEven, orThrow: TestError())
        #expect(result == 42)
    }
}
