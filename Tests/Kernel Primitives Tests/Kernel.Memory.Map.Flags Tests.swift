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

extension Kernel.Memory.Map.Flags {
    #TestSuites
}

// MARK: - Flags Tests

#if !os(Windows)

    extension Kernel.Memory.Map.Flags.Test.Unit {
        @Test("shared and private are distinct")
        func sharedAndPrivateDistinct() {
            let shared = Kernel.Memory.Map.Flags.shared
            let priv = Kernel.Memory.Map.Flags.private

            #expect(shared != priv)
            #expect(shared.rawValue != priv.rawValue)
        }

        @Test("anonymous flag exists")
        func anonymousFlagExists() {
            let anon = Kernel.Memory.Map.Flags.anonymous
            #expect(anon.rawValue != 0)
        }

        @Test("fixed flag exists")
        func fixedFlagExists() {
            let fixed = Kernel.Memory.Map.Flags.fixed
            #expect(fixed.rawValue != 0)
        }

        @Test("bitwise OR combines flags")
        func bitwiseOrCombinesFlags() {
            let priv = Kernel.Memory.Map.Flags.private
            let anon = Kernel.Memory.Map.Flags.anonymous
            let combined = priv | anon

            #expect(combined.rawValue == (priv.rawValue | anon.rawValue))
        }

        @Test("Flags is Equatable")
        func flagsIsEquatable() {
            let a = Kernel.Memory.Map.Flags.shared
            let b = Kernel.Memory.Map.Flags.shared
            let c = Kernel.Memory.Map.Flags.private

            #expect(a == b)
            #expect(a != c)
        }

        @Test("Flags is Hashable")
        func flagsIsHashable() {
            var set = Set<Kernel.Memory.Map.Flags>()
            set.insert(.shared)
            set.insert(.private)
            set.insert(.shared)  // duplicate

            #expect(set.count == 2)
            #expect(set.contains(.shared))
            #expect(set.contains(.private))
        }

        @Test("all flags are distinct")
        func allFlagsDistinct() {
            let shared = Kernel.Memory.Map.Flags.shared
            let priv = Kernel.Memory.Map.Flags.private
            let anon = Kernel.Memory.Map.Flags.anonymous
            let fixed = Kernel.Memory.Map.Flags.fixed

            let flags = [shared, priv, anon, fixed]
            let rawValues = flags.map(\.rawValue)
            let uniqueRawValues = Set(rawValues)

            #expect(uniqueRawValues.count == flags.count)
        }
    }

#endif
