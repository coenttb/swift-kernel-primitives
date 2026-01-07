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

extension Kernel.Atomic.Store {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Atomic.Store.Test.Unit {
    @Test("Store namespace exists")
    func namespaceExists() {
        _ = Kernel.Atomic.Store.self
    }

    @Test("Store is an enum")
    func isEnum() {
        let _: Kernel.Atomic.Store.Type = Kernel.Atomic.Store.self
    }
}

// MARK: - Nested Types

extension Kernel.Atomic.Store.Test.Unit {
    @Test("Store.Ordering type exists")
    func orderingTypeExists() {
        let _: Kernel.Atomic.Store.Ordering.Type = Kernel.Atomic.Store.Ordering.self
    }
}

// MARK: - Store Function Tests

extension Kernel.Atomic.Store.Test.Unit {
    @Test("store function works with Int")
    func storeInt() {
        var value: Int = 0
        Kernel.Atomic.store(&value, 42, ordering: .relaxed)
        #expect(value == 42)
    }

    @Test("store function works with UInt32")
    func storeUInt32() {
        var value: UInt32 = 0
        Kernel.Atomic.store(&value, 0xDEAD, ordering: .relaxed)
        #expect(value == 0xDEAD)
    }

    @Test("store function works with UInt64")
    func storeUInt64() {
        var value: UInt64 = 0
        Kernel.Atomic.store(&value, 0xDEAD_BEEF_CAFE_BABE, ordering: .relaxed)
        #expect(value == 0xDEAD_BEEF_CAFE_BABE)
    }

    @Test("store function works with Bool")
    func storeBool() {
        var value: Bool = false
        Kernel.Atomic.store(&value, true, ordering: .relaxed)
        #expect(value == true)
    }
}

// MARK: - Ordering Tests

extension Kernel.Atomic.Store.Test.Unit {
    @Test("store with relaxed ordering works correctly")
    func relaxedOrdering() {
        var value: Int = 0
        Kernel.Atomic.store(&value, 123, ordering: .relaxed)
        #expect(value == 123)
    }

    @Test("store with releasing ordering works correctly")
    func releasingOrdering() {
        var value: Int = 0
        Kernel.Atomic.store(&value, 456, ordering: .releasing)
        #expect(value == 456)
    }
}

// MARK: - Edge Cases

extension Kernel.Atomic.Store.Test.EdgeCase {
    @Test("store zero value")
    func storeZero() {
        var value: Int = 42
        Kernel.Atomic.store(&value, 0, ordering: .relaxed)
        #expect(value == 0)
    }

    @Test("store max Int value")
    func storeMaxInt() {
        var value: Int = 0
        Kernel.Atomic.store(&value, Int.max, ordering: .relaxed)
        #expect(value == Int.max)
    }

    @Test("store min Int value")
    func storeMinInt() {
        var value: Int = 0
        Kernel.Atomic.store(&value, Int.min, ordering: .relaxed)
        #expect(value == Int.min)
    }

    @Test("multiple stores overwrite previous values")
    func multipleStores() {
        var value: Int = 0
        Kernel.Atomic.store(&value, 1, ordering: .relaxed)
        #expect(value == 1)
        Kernel.Atomic.store(&value, 2, ordering: .relaxed)
        #expect(value == 2)
        Kernel.Atomic.store(&value, 3, ordering: .releasing)
        #expect(value == 3)
    }

    @Test("store same value multiple times")
    func storeSameValue() {
        var value: Int = 0
        Kernel.Atomic.store(&value, 42, ordering: .relaxed)
        Kernel.Atomic.store(&value, 42, ordering: .releasing)
        #expect(value == 42)
    }

    @Test("store negative values")
    func storeNegative() {
        var value: Int = 0
        Kernel.Atomic.store(&value, -12345, ordering: .relaxed)
        #expect(value == -12345)
    }
}
