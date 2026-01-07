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

extension Kernel.Socket.Shutdown.How {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Socket.Shutdown.How.Test.Unit {
    @Test("How type exists")
    func typeExists() {
        let _: Kernel.Socket.Shutdown.How.Type = Kernel.Socket.Shutdown.How.self
    }

    @Test("read case has rawValue 0")
    func readCase() {
        let how = Kernel.Socket.Shutdown.How.read
        #expect(how.rawValue == 0)
    }

    @Test("write case has rawValue 1")
    func writeCase() {
        let how = Kernel.Socket.Shutdown.How.write
        #expect(how.rawValue == 1)
    }

    @Test("both case has rawValue 2")
    func bothCase() {
        let how = Kernel.Socket.Shutdown.How.both
        #expect(how.rawValue == 2)
    }
}

// MARK: - Conformance Tests

extension Kernel.Socket.Shutdown.How.Test.Unit {
    @Test("How is Sendable")
    func isSendable() {
        let value: any Sendable = Kernel.Socket.Shutdown.How.read
        #expect(value is Kernel.Socket.Shutdown.How)
    }

    @Test("How is Equatable")
    func isEquatable() {
        #expect(Kernel.Socket.Shutdown.How.read == Kernel.Socket.Shutdown.How.read)
        #expect(Kernel.Socket.Shutdown.How.read != Kernel.Socket.Shutdown.How.write)
    }

    @Test("How is Hashable")
    func isHashable() {
        var set = Set<Kernel.Socket.Shutdown.How>()
        set.insert(.read)
        set.insert(.write)
        set.insert(.both)
        set.insert(.read)  // duplicate
        #expect(set.count == 3)
    }
}

// MARK: - RawValue Roundtrip Tests

extension Kernel.Socket.Shutdown.How.Test.Unit {
    @Test("How from rawValue 0 is read")
    func fromRawValue0() {
        let how = Kernel.Socket.Shutdown.How(rawValue: 0)
        #expect(how == .read)
    }

    @Test("How from rawValue 1 is write")
    func fromRawValue1() {
        let how = Kernel.Socket.Shutdown.How(rawValue: 1)
        #expect(how == .write)
    }

    @Test("How from rawValue 2 is both")
    func fromRawValue2() {
        let how = Kernel.Socket.Shutdown.How(rawValue: 2)
        #expect(how == .both)
    }
}

// MARK: - Edge Cases

extension Kernel.Socket.Shutdown.How.Test.EdgeCase {
    @Test("How from invalid rawValue is nil")
    func invalidRawValue() {
        let how = Kernel.Socket.Shutdown.How(rawValue: 99)
        #expect(how == nil)
    }

    @Test("All cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.Socket.Shutdown.How] = [.read, .write, .both]
        let rawValues = cases.map(\.rawValue)
        let uniqueRawValues = Set(rawValues)
        #expect(uniqueRawValues.count == cases.count)
    }
}
