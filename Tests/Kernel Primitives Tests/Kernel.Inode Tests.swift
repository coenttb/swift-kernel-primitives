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

extension Kernel.Inode {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Inode.Test.Unit {
    @Test("Inode type exists")
    func typeExists() {
        let _: Kernel.Inode.Type = Kernel.Inode.self
    }

    @Test("Inode from rawValue")
    func fromRawValue() {
        let inode = Kernel.Inode(rawValue: 12345)
        #expect(inode.rawValue == 12345)
    }

    @Test("Inode from UInt64")
    func fromUInt64() {
        let inode = Kernel.Inode(67890)
        #expect(inode.rawValue == 67890)
    }
}

// MARK: - ExpressibleByIntegerLiteral Tests

extension Kernel.Inode.Test.Unit {
    @Test("Inode from integer literal")
    func fromIntegerLiteral() {
        let inode: Kernel.Inode = 42
        #expect(inode.rawValue == 42)
    }
}

// MARK: - Conformance Tests

extension Kernel.Inode.Test.Unit {
    @Test("Inode is Sendable")
    func isSendable() {
        let value: any Sendable = Kernel.Inode(0)
        #expect(value is Kernel.Inode)
    }

    @Test("Inode is Equatable")
    func isEquatable() {
        let a = Kernel.Inode(100)
        let b = Kernel.Inode(100)
        let c = Kernel.Inode(200)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Inode is Hashable")
    func isHashable() {
        var set = Set<Kernel.Inode>()
        set.insert(Kernel.Inode(1))
        set.insert(Kernel.Inode(2))
        set.insert(Kernel.Inode(1))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - CustomStringConvertible Tests

extension Kernel.Inode.Test.Unit {
    @Test("Inode description shows raw value")
    func description() {
        let inode = Kernel.Inode(12345)
        #expect(inode.description == "12345")
    }
}

// MARK: - Edge Cases

extension Kernel.Inode.Test.EdgeCase {
    @Test("Inode zero")
    func zeroInode() {
        let inode = Kernel.Inode(0)
        #expect(inode.rawValue == 0)
    }

    @Test("Inode max value")
    func maxValue() {
        let inode = Kernel.Inode(UInt64.max)
        #expect(inode.rawValue == UInt64.max)
    }

    @Test("Inode rawValue roundtrip")
    func rawValueRoundtrip() {
        for value: UInt64 in [0, 1, 100, 12_345_678, UInt64.max] {
            let inode = Kernel.Inode(rawValue: value)
            #expect(inode.rawValue == value)
        }
    }
}
