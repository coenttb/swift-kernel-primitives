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

extension Kernel.Group {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Group.Test.Unit {
    @Test("Group namespace exists")
    func namespaceExists() {
        _ = Kernel.Group.self
    }

    @Test("Group is an enum")
    func isEnum() {
        let _: Kernel.Group.Type = Kernel.Group.self
    }

    @Test("Group.ID type exists")
    func idTypeExists() {
        let _: Kernel.Group.ID.Type = Kernel.Group.ID.self
    }
}

// MARK: - Group.ID Tests

extension Kernel.Group.Test.Unit {
    @Test("Group.ID from UInt32")
    func idFromUInt32() {
        let gid = Kernel.Group.ID(100)
        #expect(gid == 100)
    }

    @Test("Group.ID root constant")
    func rootConstant() {
        let root = Kernel.Group.ID.root
        #expect(root == 0)
    }
}

// MARK: - Group.ID Conformance Tests

extension Kernel.Group.Test.Unit {
    @Test("Group.ID is Sendable")
    func idIsSendable() {
        let value: any Sendable = Kernel.Group.ID(0)
        #expect(value is Kernel.Group.ID)
    }

    @Test("Group.ID is Equatable")
    func idIsEquatable() {
        let a = Kernel.Group.ID(100)
        let b = Kernel.Group.ID(100)
        let c = Kernel.Group.ID(200)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Group.ID is Hashable")
    func idIsHashable() {
        var set = Set<Kernel.Group.ID>()
        set.insert(Kernel.Group.ID(1))
        set.insert(Kernel.Group.ID(2))
        set.insert(Kernel.Group.ID(1))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Group.Test.EdgeCase {
    @Test("Group.ID zero is root")
    func zeroIsRoot() {
        let gid = Kernel.Group.ID(0)
        #expect(gid == .root)
    }

    @Test("Group.ID rawValue roundtrip")
    func rawValueRoundtrip() {
        for value: UInt32 in [0, 1, 100, 1000, UInt32.max] {
            let gid = Kernel.Group.ID(value)
            #expect(gid.rawValue == value)
        }
    }
}
