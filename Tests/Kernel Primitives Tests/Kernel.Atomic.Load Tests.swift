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

extension Kernel.Atomic.Load {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Atomic.Load.Test.Unit {
    @Test("Load namespace exists")
    func namespaceExists() {
        _ = Kernel.Atomic.Load.self
    }

    @Test("Load is an enum")
    func isEnum() {
        let _: Kernel.Atomic.Load.Type = Kernel.Atomic.Load.self
    }
}

// MARK: - Nested Types

extension Kernel.Atomic.Load.Test.Unit {
    @Test("Load.Ordering type exists")
    func orderingTypeExists() {
        let _: Kernel.Atomic.Load.Ordering.Type = Kernel.Atomic.Load.Ordering.self
    }
}

// MARK: - Load Function Tests

extension Kernel.Atomic.Load.Test.Unit {
    @Test("load function works with Int")
    func loadInt() {
        var value: Int = 42
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == 42)
    }

    @Test("load function works with UInt32")
    func loadUInt32() {
        var value: UInt32 = 0xDEAD
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == 0xDEAD)
    }

    @Test("load function works with UInt64")
    func loadUInt64() {
        var value: UInt64 = 0xDEAD_BEEF_CAFE_BABE
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == 0xDEAD_BEEF_CAFE_BABE)
    }

    @Test("load function works with Bool")
    func loadBool() {
        var value: Bool = true
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == true)
    }
}

// MARK: - Ordering Tests

extension Kernel.Atomic.Load.Test.Unit {
    @Test("load with relaxed ordering returns correct value")
    func relaxedOrdering() {
        var value: Int = 123
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == 123)
    }

    @Test("load with acquiring ordering returns correct value")
    func acquiringOrdering() {
        var value: Int = 456
        let loaded = Kernel.Atomic.load(&value, ordering: .acquiring)
        #expect(loaded == 456)
    }
}

// MARK: - Edge Cases

extension Kernel.Atomic.Load.Test.EdgeCase {
    @Test("load zero value")
    func loadZero() {
        var value: Int = 0
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == 0)
    }

    @Test("load max Int value")
    func loadMaxInt() {
        var value: Int = Int.max
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == Int.max)
    }

    @Test("load min Int value")
    func loadMinInt() {
        var value: Int = Int.min
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == Int.min)
    }

    @Test("multiple loads return same value")
    func multipleLoads() {
        var value: Int = 42
        let loaded1 = Kernel.Atomic.load(&value, ordering: .relaxed)
        let loaded2 = Kernel.Atomic.load(&value, ordering: .relaxed)
        let loaded3 = Kernel.Atomic.load(&value, ordering: .acquiring)
        #expect(loaded1 == loaded2)
        #expect(loaded2 == loaded3)
    }

    @Test("load does not modify original value")
    func loadDoesNotModify() {
        var value: Int = 42
        _ = Kernel.Atomic.load(&value, ordering: .relaxed)
        _ = Kernel.Atomic.load(&value, ordering: .acquiring)
        #expect(value == 42)
    }
}
