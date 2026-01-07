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

extension Kernel.Link {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Link.Test.Unit {
    @Test("Link namespace exists")
    func namespaceExists() {
        _ = Kernel.Link.self
    }

    @Test("Link is an enum")
    func isEnum() {
        let _: Kernel.Link.Type = Kernel.Link.self
    }

    @Test("Link.Count type exists")
    func countTypeExists() {
        let _: Kernel.Link.Count.Type = Kernel.Link.Count.self
    }
}

// MARK: - Link.Count Tests

extension Kernel.Link.Test.Unit {
    @Test("Link.Count from UInt32")
    func countFromUInt32() {
        let count = Kernel.Link.Count(5)
        #expect(count == 5)
    }

    @Test("Link.Count.one constant")
    func oneConstant() {
        let one = Kernel.Link.Count.one
        #expect(one == 1)
    }

    @Test("Link.Count.zero constant")
    func zeroConstant() {
        let zero = Kernel.Link.Count.zero
        #expect(zero == 0)
    }
}

// MARK: - Link.Count Conformance Tests

extension Kernel.Link.Test.Unit {
    @Test("Link.Count is Sendable")
    func countIsSendable() {
        let value: any Sendable = Kernel.Link.Count(0)
        #expect(value is Kernel.Link.Count)
    }

    @Test("Link.Count is Equatable")
    func countIsEquatable() {
        let a = Kernel.Link.Count(1)
        let b = Kernel.Link.Count(1)
        let c = Kernel.Link.Count(2)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Link.Count is Hashable")
    func countIsHashable() {
        var set = Set<Kernel.Link.Count>()
        set.insert(.zero)
        set.insert(.one)
        set.insert(.zero)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Link.Test.EdgeCase {
    @Test("Link.Count comparison with constants")
    func countComparison() {
        let one = Kernel.Link.Count(1)
        #expect(one == .one)

        let zero = Kernel.Link.Count(0)
        #expect(zero == .zero)
    }

    @Test("Link.Count rawValue roundtrip")
    func rawValueRoundtrip() {
        for value: UInt32 in [0, 1, 2, 100, UInt32.max] {
            let count = Kernel.Link.Count(value)
            #expect(count.rawValue == value)
        }
    }
}
