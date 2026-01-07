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

extension Kernel.Socket.Backlog {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Socket.Backlog.Test.Unit {
    @Test("Backlog type exists")
    func typeExists() {
        let _: Kernel.Socket.Backlog.Type = Kernel.Socket.Backlog.self
    }

    @Test("Backlog from rawValue")
    func fromRawValue() {
        let backlog = Kernel.Socket.Backlog(rawValue: 64)
        #expect(backlog.rawValue == 64)
    }

    @Test("Backlog from Int32")
    func fromInt32() {
        let backlog = Kernel.Socket.Backlog(256)
        #expect(backlog.rawValue == 256)
    }
}

// MARK: - Constants Tests

extension Kernel.Socket.Backlog.Test.Unit {
    @Test("Backlog.default is 128")
    func defaultConstant() {
        #expect(Kernel.Socket.Backlog.default.rawValue == 128)
    }

    @Test("Backlog.small is 16")
    func smallConstant() {
        #expect(Kernel.Socket.Backlog.small.rawValue == 16)
    }

    @Test("Backlog.large is 4096")
    func largeConstant() {
        #expect(Kernel.Socket.Backlog.large.rawValue == 4096)
    }

    #if !os(Windows)
        @Test("Backlog.max uses SOMAXCONN")
        func maxConstant() {
            let max = Kernel.Socket.Backlog.max
            #expect(max.rawValue > 0)
        }
    #endif
}

// MARK: - ExpressibleByIntegerLiteral Tests

extension Kernel.Socket.Backlog.Test.Unit {
    @Test("Backlog from integer literal")
    func fromIntegerLiteral() {
        let backlog: Kernel.Socket.Backlog = 512
        #expect(backlog.rawValue == 512)
    }
}

// MARK: - Conformance Tests

extension Kernel.Socket.Backlog.Test.Unit {
    @Test("Backlog is Sendable")
    func isSendable() {
        let value: any Sendable = Kernel.Socket.Backlog.default
        #expect(value is Kernel.Socket.Backlog)
    }

    @Test("Backlog is Equatable")
    func isEquatable() {
        let a = Kernel.Socket.Backlog(128)
        let b = Kernel.Socket.Backlog(128)
        let c = Kernel.Socket.Backlog(256)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Backlog is Hashable")
    func isHashable() {
        var set = Set<Kernel.Socket.Backlog>()
        set.insert(.default)
        set.insert(.small)
        set.insert(.default)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - CustomStringConvertible Tests

extension Kernel.Socket.Backlog.Test.Unit {
    @Test("Backlog description shows raw value")
    func description() {
        let backlog = Kernel.Socket.Backlog(100)
        #expect(backlog.description == "100")
    }
}

// MARK: - Edge Cases

extension Kernel.Socket.Backlog.Test.EdgeCase {
    @Test("Backlog zero")
    func zeroBacklog() {
        let backlog = Kernel.Socket.Backlog(0)
        #expect(backlog.rawValue == 0)
    }

    @Test("Backlog negative")
    func negativeBacklog() {
        let backlog = Kernel.Socket.Backlog(-1)
        #expect(backlog.rawValue == -1)
    }

    @Test("Backlog rawValue roundtrip")
    func rawValueRoundtrip() {
        for value: Int32 in [0, 1, 16, 128, 4096, Int32.max] {
            let backlog = Kernel.Socket.Backlog(rawValue: value)
            #expect(backlog.rawValue == value)
        }
    }
}
