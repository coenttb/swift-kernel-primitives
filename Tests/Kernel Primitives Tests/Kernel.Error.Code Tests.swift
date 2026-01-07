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

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension Kernel.Error.Code {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Error.Code.Test.Unit {
    @Test("posix case stores Int32 value")
    func posixCase() {
        let code = Kernel.Error.Code.posix(42)
        if case .posix(let value) = code {
            #expect(value == 42)
        } else {
            Issue.record("Expected .posix case")
        }
    }

    @Test("win32 case stores UInt32 value")
    func win32Case() {
        let code = Kernel.Error.Code.win32(42)
        if case .win32(let value) = code {
            #expect(value == 42)
        } else {
            Issue.record("Expected .win32 case")
        }
    }

    @Test("posix accessor returns value for posix code")
    func posixAccessor() {
        let code = Kernel.Error.Code.posix(123)
        #expect(code.posix == 123)
    }

    @Test("posix accessor returns nil for win32 code")
    func posixAccessorReturnsNil() {
        let code = Kernel.Error.Code.win32(123)
        #expect(code.posix == nil)
    }

    @Test("win32 accessor returns value for win32 code")
    func win32Accessor() {
        let code = Kernel.Error.Code.win32(456)
        #expect(code.win32 == 456)
    }

    @Test("win32 accessor returns nil for posix code")
    func win32AccessorReturnsNil() {
        let code = Kernel.Error.Code.posix(456)
        #expect(code.win32 == nil)
    }
}

// MARK: - Description Tests

extension Kernel.Error.Code.Test.Unit {
    @Test("posix description format")
    func posixDescription() {
        let code = Kernel.Error.Code.posix(22)
        #expect(code.description == "posix(22)")
    }

    @Test("win32 description format")
    func win32Description() {
        let code = Kernel.Error.Code.win32(5)
        #expect(code.description == "win32(5)")
    }
}

// MARK: - Conformance Tests

extension Kernel.Error.Code.Test.Unit {
    @Test("Code is Sendable")
    func isSendable() {
        let code: any Sendable = Kernel.Error.Code.posix(1)
        #expect(code is Kernel.Error.Code)
    }

    @Test("Code is Equatable")
    func isEquatable() {
        let a = Kernel.Error.Code.posix(1)
        let b = Kernel.Error.Code.posix(1)
        let c = Kernel.Error.Code.posix(2)
        let d = Kernel.Error.Code.win32(1)
        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
    }

    @Test("Code is Hashable")
    func isHashable() {
        var set = Set<Kernel.Error.Code>()
        set.insert(.posix(1))
        set.insert(.win32(1))
        set.insert(.posix(1))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Error.Code.Test.EdgeCase {
    @Test("posix with negative value")
    func posixNegative() {
        let code = Kernel.Error.Code.posix(-1)
        #expect(code.posix == -1)
    }

    @Test("posix with max Int32")
    func posixMaxInt32() {
        let code = Kernel.Error.Code.posix(Int32.max)
        #expect(code.posix == Int32.max)
    }

    @Test("posix with min Int32")
    func posixMinInt32() {
        let code = Kernel.Error.Code.posix(Int32.min)
        #expect(code.posix == Int32.min)
    }

    @Test("win32 with max UInt32")
    func win32MaxUInt32() {
        let code = Kernel.Error.Code.win32(UInt32.max)
        #expect(code.win32 == UInt32.max)
    }

    @Test("win32 with zero")
    func win32Zero() {
        let code = Kernel.Error.Code.win32(0)
        #expect(code.win32 == 0)
    }
}

// MARK: - Platform-Specific Tests

#if !os(Windows)
    extension Kernel.Error.Code.Test.Unit {
        @Test("common POSIX errno values")
        func commonPosixErrno() {
            let ebadf = Kernel.Error.Code.posix(EBADF)
            #expect(ebadf.posix == EBADF)

            let einval = Kernel.Error.Code.posix(EINVAL)
            #expect(einval.posix == EINVAL)

            let enoent = Kernel.Error.Code.posix(ENOENT)
            #expect(enoent.posix == ENOENT)
        }
    }
#endif
