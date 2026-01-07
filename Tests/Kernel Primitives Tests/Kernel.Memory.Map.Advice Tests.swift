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

extension Kernel.Memory.Map.Advice {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Memory.Map.Advice.Test.Unit {
    @Test("Advice from rawValue")
    func rawValueInit() {
        let advice = Kernel.Memory.Map.Advice(rawValue: 0)
        #expect(advice.rawValue == 0)
    }

    @Test("normal constant exists")
    func normalConstant() {
        let advice = Kernel.Memory.Map.Advice.normal
        // Normal is typically 0 on most platforms
        _ = advice.rawValue
    }

    @Test("sequential constant exists")
    func sequentialConstant() {
        let advice = Kernel.Memory.Map.Advice.sequential
        _ = advice.rawValue
    }

    @Test("random constant exists")
    func randomConstant() {
        let advice = Kernel.Memory.Map.Advice.random
        _ = advice.rawValue
    }

    @Test("willNeed constant exists")
    func willNeedConstant() {
        let advice = Kernel.Memory.Map.Advice.willNeed
        _ = advice.rawValue
    }

    @Test("dontNeed constant exists")
    func dontNeedConstant() {
        let advice = Kernel.Memory.Map.Advice.dontNeed
        _ = advice.rawValue
    }
}

// MARK: - Conformance Tests

extension Kernel.Memory.Map.Advice.Test.Unit {
    @Test("Advice is Sendable")
    func isSendable() {
        let advice: any Sendable = Kernel.Memory.Map.Advice.normal
        #expect(advice is Kernel.Memory.Map.Advice)
    }

    @Test("Advice is Equatable")
    func isEquatable() {
        let a = Kernel.Memory.Map.Advice.normal
        let b = Kernel.Memory.Map.Advice.normal
        let c = Kernel.Memory.Map.Advice.sequential
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Advice is Hashable")
    func isHashable() {
        var set = Set<Kernel.Memory.Map.Advice>()
        set.insert(.normal)
        set.insert(.sequential)
        set.insert(.normal)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Memory.Map.Advice.Test.EdgeCase {
    @Test("all advice types are distinct")
    func allAdviceDistinct() {
        let advices: [Kernel.Memory.Map.Advice] = [
            .normal,
            .sequential,
            .random,
            .willNeed,
            .dontNeed,
        ]

        for i in 0..<advices.count {
            for j in (i + 1)..<advices.count {
                #expect(advices[i] != advices[j])
            }
        }
    }
}
