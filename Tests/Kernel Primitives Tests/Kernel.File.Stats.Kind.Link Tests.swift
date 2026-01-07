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

extension Kernel.File.Stats.Kind.Link {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Stats.Kind.Link.Test.Unit {
    @Test("symbolic case exists")
    func symbolicCase() {
        let link = Kernel.File.Stats.Kind.Link.symbolic
        if case .symbolic = link {
            // Expected
        } else {
            Issue.record("Expected .symbolic case")
        }
    }

    @Test("junction case exists")
    func junctionCase() {
        let link = Kernel.File.Stats.Kind.Link.junction
        if case .junction = link {
            // Expected
        } else {
            Issue.record("Expected .junction case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Stats.Kind.Link.Test.Unit {
    @Test("Link is Sendable")
    func isSendable() {
        let link: any Sendable = Kernel.File.Stats.Kind.Link.symbolic
        #expect(link is Kernel.File.Stats.Kind.Link)
    }

    @Test("Link is Equatable")
    func isEquatable() {
        let a = Kernel.File.Stats.Kind.Link.symbolic
        let b = Kernel.File.Stats.Kind.Link.symbolic
        let c = Kernel.File.Stats.Kind.Link.junction
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Link is Hashable")
    func isHashable() {
        var set = Set<Kernel.File.Stats.Kind.Link>()
        set.insert(.symbolic)
        set.insert(.junction)
        set.insert(.symbolic)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Stats.Kind.Link.Test.EdgeCase {
    @Test("symbolic and junction are distinct")
    func casesDistinct() {
        let symbolic = Kernel.File.Stats.Kind.Link.symbolic
        let junction = Kernel.File.Stats.Kind.Link.junction
        #expect(symbolic != junction)
    }
}
