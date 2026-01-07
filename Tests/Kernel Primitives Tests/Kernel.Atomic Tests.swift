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

extension Kernel.Atomic {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Atomic.Test.Unit {
    @Test("Atomic namespace exists")
    func namespaceExists() {
        _ = Kernel.Atomic.self
    }

    @Test("Atomic is an enum")
    func isEnum() {
        let _: Kernel.Atomic.Type = Kernel.Atomic.self
    }
}

// MARK: - Nested Types

extension Kernel.Atomic.Test.Unit {
    @Test("Atomic.Load type exists")
    func loadTypeExists() {
        let _: Kernel.Atomic.Load.Type = Kernel.Atomic.Load.self
    }

    @Test("Atomic.Store type exists")
    func storeTypeExists() {
        let _: Kernel.Atomic.Store.Type = Kernel.Atomic.Store.self
    }
}

// MARK: - Load Operation Tests

extension Kernel.Atomic.Test.Unit {
    @Test("load with relaxed ordering")
    func loadRelaxed() {
        var value: Int = 42
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == 42)
    }

    @Test("load with acquiring ordering")
    func loadAcquiring() {
        var value: Int = 100
        let loaded = Kernel.Atomic.load(&value, ordering: .acquiring)
        #expect(loaded == 100)
    }

    @Test("load preserves value")
    func loadPreservesValue() {
        var value: UInt64 = 0xDEAD_BEEF
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == 0xDEAD_BEEF)
        #expect(value == 0xDEAD_BEEF)
    }
}

// MARK: - Store Operation Tests

extension Kernel.Atomic.Test.Unit {
    @Test("store with relaxed ordering")
    func storeRelaxed() {
        var value: Int = 0
        Kernel.Atomic.store(&value, 42, ordering: .relaxed)
        #expect(value == 42)
    }

    @Test("store with releasing ordering")
    func storeReleasing() {
        var value: Int = 0
        Kernel.Atomic.store(&value, 100, ordering: .releasing)
        #expect(value == 100)
    }

    @Test("store overwrites previous value")
    func storeOverwrites() {
        var value: UInt64 = 0xDEAD_BEEF
        Kernel.Atomic.store(&value, 0xCAFE_BABE, ordering: .relaxed)
        #expect(value == 0xCAFE_BABE)
    }
}

// MARK: - Edge Cases

extension Kernel.Atomic.Test.EdgeCase {
    @Test("load and store with zero")
    func zeroValue() {
        var value: Int = 42
        Kernel.Atomic.store(&value, 0, ordering: .relaxed)
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == 0)
    }

    @Test("load and store with max value")
    func maxValue() {
        var value: UInt64 = 0
        Kernel.Atomic.store(&value, UInt64.max, ordering: .relaxed)
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == UInt64.max)
    }

    @Test("load and store with negative value")
    func negativeValue() {
        var value: Int64 = 0
        Kernel.Atomic.store(&value, -12345, ordering: .relaxed)
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == -12345)
    }

    @Test("sequential stores are visible")
    func sequentialStores() {
        var value: Int = 0
        Kernel.Atomic.store(&value, 1, ordering: .relaxed)
        Kernel.Atomic.store(&value, 2, ordering: .relaxed)
        Kernel.Atomic.store(&value, 3, ordering: .relaxed)
        let loaded = Kernel.Atomic.load(&value, ordering: .relaxed)
        #expect(loaded == 3)
    }

    @Test("different orderings produce same result for single thread")
    func orderingsEquivalentSingleThread() {
        var value1: Int = 0
        var value2: Int = 0

        Kernel.Atomic.store(&value1, 42, ordering: .relaxed)
        Kernel.Atomic.store(&value2, 42, ordering: .releasing)

        let loaded1 = Kernel.Atomic.load(&value1, ordering: .relaxed)
        let loaded2 = Kernel.Atomic.load(&value2, ordering: .acquiring)

        #expect(loaded1 == loaded2)
    }
}
