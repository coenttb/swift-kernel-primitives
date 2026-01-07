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

extension Kernel.Memory.Map.Sync.Flags {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Memory.Map.Sync.Flags.Test.Unit {
    @Test("Flags from rawValue")
    func rawValueInit() {
        let flags = Kernel.Memory.Map.Sync.Flags(rawValue: 0)
        #expect(flags.rawValue == 0)
    }

    @Test("sync constant exists")
    func syncConstant() {
        let flags = Kernel.Memory.Map.Sync.Flags.sync
        _ = flags.rawValue
    }

    @Test("async constant exists")
    func asyncConstant() {
        let flags = Kernel.Memory.Map.Sync.Flags.async
        _ = flags.rawValue
    }

    @Test("invalidate constant exists")
    func invalidateConstant() {
        let flags = Kernel.Memory.Map.Sync.Flags.invalidate
        _ = flags.rawValue
    }
}

// MARK: - Operators

extension Kernel.Memory.Map.Sync.Flags.Test.Unit {
    @Test("bitwise OR combines flags")
    func bitwiseOrCombines() {
        let sync = Kernel.Memory.Map.Sync.Flags.sync
        let invalidate = Kernel.Memory.Map.Sync.Flags.invalidate
        let combined = sync | invalidate

        #expect(combined.rawValue == (sync.rawValue | invalidate.rawValue))
    }
}

// MARK: - Conformance Tests

extension Kernel.Memory.Map.Sync.Flags.Test.Unit {
    @Test("Flags is Sendable")
    func isSendable() {
        let flags: any Sendable = Kernel.Memory.Map.Sync.Flags.sync
        #expect(flags is Kernel.Memory.Map.Sync.Flags)
    }

    @Test("Flags is Equatable")
    func isEquatable() {
        let a = Kernel.Memory.Map.Sync.Flags.sync
        let b = Kernel.Memory.Map.Sync.Flags.sync
        let c = Kernel.Memory.Map.Sync.Flags.async
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Flags is Hashable")
    func isHashable() {
        var set = Set<Kernel.Memory.Map.Sync.Flags>()
        set.insert(.sync)
        set.insert(.async)
        set.insert(.sync)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Memory.Map.Sync.Flags.Test.EdgeCase {
    @Test("sync and async are distinct")
    func syncAsyncDistinct() {
        let sync = Kernel.Memory.Map.Sync.Flags.sync
        let async = Kernel.Memory.Map.Sync.Flags.async
        #expect(sync != async)
    }

    @Test("all flags are distinct")
    func allFlagsDistinct() {
        let flags: [Kernel.Memory.Map.Sync.Flags] = [
            .sync,
            .async,
            .invalidate,
        ]

        for i in 0..<flags.count {
            for j in (i + 1)..<flags.count {
                #expect(flags[i] != flags[j])
            }
        }
    }
}
