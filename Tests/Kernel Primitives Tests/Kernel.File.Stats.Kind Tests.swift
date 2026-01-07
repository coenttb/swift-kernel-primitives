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

extension Kernel.File.Stats.Kind {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Stats.Kind.Test.Unit {
    @Test("regular case exists")
    func regularCase() {
        let kind = Kernel.File.Stats.Kind.regular
        if case .regular = kind {
            // Expected
        } else {
            Issue.record("Expected .regular case")
        }
    }

    @Test("directory case exists")
    func directoryCase() {
        let kind = Kernel.File.Stats.Kind.directory
        if case .directory = kind {
            // Expected
        } else {
            Issue.record("Expected .directory case")
        }
    }

    @Test("link case exists")
    func linkCase() {
        let kind = Kernel.File.Stats.Kind.link(.symbolic)
        if case .link = kind {
            // Expected
        } else {
            Issue.record("Expected .link case")
        }
    }

    @Test("device case exists")
    func deviceCase() {
        let kind = Kernel.File.Stats.Kind.device(.block)
        if case .device = kind {
            // Expected
        } else {
            Issue.record("Expected .device case")
        }
    }

    @Test("fifo case exists")
    func fifoCase() {
        let kind = Kernel.File.Stats.Kind.fifo
        if case .fifo = kind {
            // Expected
        } else {
            Issue.record("Expected .fifo case")
        }
    }

    @Test("socket case exists")
    func socketCase() {
        let kind = Kernel.File.Stats.Kind.socket
        if case .socket = kind {
            // Expected
        } else {
            Issue.record("Expected .socket case")
        }
    }

    @Test("unknown case exists")
    func unknownCase() {
        let kind = Kernel.File.Stats.Kind.unknown
        if case .unknown = kind {
            // Expected
        } else {
            Issue.record("Expected .unknown case")
        }
    }
}

// MARK: - Nested Types

extension Kernel.File.Stats.Kind.Test.Unit {
    @Test("Device type exists")
    func deviceTypeExists() {
        let _: Kernel.File.Stats.Kind.Device.Type = Kernel.File.Stats.Kind.Device.self
    }

    @Test("Link type exists")
    func linkTypeExists() {
        let _: Kernel.File.Stats.Kind.Link.Type = Kernel.File.Stats.Kind.Link.self
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Stats.Kind.Test.Unit {
    @Test("Kind is Sendable")
    func isSendable() {
        let kind: any Sendable = Kernel.File.Stats.Kind.regular
        #expect(kind is Kernel.File.Stats.Kind)
    }

    @Test("Kind is Equatable")
    func isEquatable() {
        let a = Kernel.File.Stats.Kind.regular
        let b = Kernel.File.Stats.Kind.regular
        let c = Kernel.File.Stats.Kind.directory
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Kind is Hashable")
    func isHashable() {
        var set = Set<Kernel.File.Stats.Kind>()
        set.insert(.regular)
        set.insert(.directory)
        set.insert(.regular)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Stats.Kind.Test.EdgeCase {
    @Test("all simple cases are distinct")
    func simpleCasesDistinct() {
        let cases: [Kernel.File.Stats.Kind] = [
            .regular,
            .directory,
            .fifo,
            .socket,
            .unknown,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("link cases with different types are distinct")
    func linkTypesDistinct() {
        let symbolic = Kernel.File.Stats.Kind.link(.symbolic)
        let junction = Kernel.File.Stats.Kind.link(.junction)
        #expect(symbolic != junction)
    }

    @Test("device cases with different types are distinct")
    func deviceTypesDistinct() {
        let block = Kernel.File.Stats.Kind.device(.block)
        let character = Kernel.File.Stats.Kind.device(.character)
        #expect(block != character)
    }

    @Test("link and device are distinct from simple cases")
    func compositeDistinctFromSimple() {
        let link = Kernel.File.Stats.Kind.link(.symbolic)
        let device = Kernel.File.Stats.Kind.device(.block)
        let regular = Kernel.File.Stats.Kind.regular

        #expect(link != regular)
        #expect(device != regular)
        #expect(link != device)
    }
}
