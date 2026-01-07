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

extension Kernel.User {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.User.Test.Unit {
    @Test("User namespace exists")
    func namespaceExists() {
        _ = Kernel.User.self
    }

    @Test("User is an enum")
    func isEnum() {
        let _: Kernel.User.Type = Kernel.User.self
    }

    @Test("User.ID type exists")
    func idTypeExists() {
        let _: Kernel.User.ID.Type = Kernel.User.ID.self
    }
}

// MARK: - User.ID Tests

extension Kernel.User.Test.Unit {
    @Test("User.ID from UInt32")
    func idFromUInt32() {
        let uid = Kernel.User.ID(501)
        #expect(uid == 501)
    }

    @Test("User.ID root constant")
    func rootConstant() {
        let root = Kernel.User.ID.root
        #expect(root == 0)
    }
}

// MARK: - User.ID Conformance Tests

extension Kernel.User.Test.Unit {
    @Test("User.ID is Sendable")
    func idIsSendable() {
        let value: any Sendable = Kernel.User.ID(0)
        #expect(value is Kernel.User.ID)
    }

    @Test("User.ID is Equatable")
    func idIsEquatable() {
        let a = Kernel.User.ID(501)
        let b = Kernel.User.ID(501)
        let c = Kernel.User.ID(502)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("User.ID is Hashable")
    func idIsHashable() {
        var set = Set<Kernel.User.ID>()
        set.insert(Kernel.User.ID(501))
        set.insert(Kernel.User.ID(502))
        set.insert(Kernel.User.ID(501))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.User.Test.EdgeCase {
    @Test("User.ID zero is root")
    func zeroIsRoot() {
        let uid = Kernel.User.ID(0)
        #expect(uid == .root)
    }

    @Test("User.ID rawValue roundtrip")
    func rawValueRoundtrip() {
        for value: UInt32 in [0, 1, 501, 65534, UInt32.max] {
            let uid = Kernel.User.ID(value)
            #expect(uid.rawValue == value)
        }
    }
}
