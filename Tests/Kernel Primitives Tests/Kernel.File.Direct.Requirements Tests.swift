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

import Binary
import StandardsTestSupport
import Testing

@testable import Kernel_Primitives

extension Kernel.File.Direct.Requirements {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Requirements.Test.Unit {
    @Test("known case exists")
    func knownCase() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let requirements = Kernel.File.Direct.Requirements.known(alignment)
        if case .known = requirements {
            // Expected
        } else {
            Issue.record("Expected .known case")
        }
    }

    @Test("unknown case exists")
    func unknownCase() {
        let requirements = Kernel.File.Direct.Requirements.unknown(reason: .platformUnsupported)
        if case .unknown = requirements {
            // Expected
        } else {
            Issue.record("Expected .unknown case")
        }
    }
}

// MARK: - Initializer Tests

extension Kernel.File.Direct.Requirements.Test.Unit {
    @Test("init with explicit alignment values")
    func initExplicitAlignment() {
        let requirements = Kernel.File.Direct.Requirements(
            bufferAlignment: .`512`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`512`
        )
        if case .known(let alignment) = requirements {
            #expect(alignment.bufferAlignment == .`512`)
            #expect(alignment.offsetAlignment == .`4096`)
            #expect(alignment.lengthMultiple == .`512`)
        } else {
            Issue.record("Expected .known case")
        }
    }

    @Test("init with uniform alignment")
    func initUniformAlignment() {
        let requirements = Kernel.File.Direct.Requirements(uniformAlignment: .`4096`)
        if case .known(let alignment) = requirements {
            #expect(alignment.bufferAlignment == .`4096`)
            #expect(alignment.offsetAlignment == .`4096`)
            #expect(alignment.lengthMultiple == .`4096`)
        } else {
            Issue.record("Expected .known case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Requirements.Test.Unit {
    @Test("Requirements is Sendable")
    func isSendable() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let requirements: any Sendable = Kernel.File.Direct.Requirements.known(alignment)
        #expect(requirements is Kernel.File.Direct.Requirements)
    }

    @Test("Requirements is Equatable")
    func isEquatable() {
        let align1 = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let align2 = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let a = Kernel.File.Direct.Requirements.known(align1)
        let b = Kernel.File.Direct.Requirements.known(align2)
        let c = Kernel.File.Direct.Requirements.unknown(reason: .platformUnsupported)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Nested Types

extension Kernel.File.Direct.Requirements.Test.Unit {
    @Test("Alignment type exists")
    func alignmentTypeExists() {
        let _: Kernel.File.Direct.Requirements.Alignment.Type = Kernel.File.Direct.Requirements.Alignment.self
    }

    @Test("Reason type exists")
    func reasonTypeExists() {
        let _: Kernel.File.Direct.Requirements.Reason.Type = Kernel.File.Direct.Requirements.Reason.self
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Requirements.Test.EdgeCase {
    @Test("known with different alignments are distinct")
    func knownDistinct() {
        let align1 = Kernel.File.Direct.Requirements.Alignment(uniform: .`512`)
        let align2 = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let req1 = Kernel.File.Direct.Requirements.known(align1)
        let req2 = Kernel.File.Direct.Requirements.known(align2)
        #expect(req1 != req2)
    }

    @Test("unknown with different reasons are distinct")
    func unknownDistinct() {
        let req1 = Kernel.File.Direct.Requirements.unknown(reason: .platformUnsupported)
        let req2 = Kernel.File.Direct.Requirements.unknown(reason: .sectorSizeUndetermined)
        #expect(req1 != req2)
    }

    @Test("known and unknown are distinct")
    func knownUnknownDistinct() {
        let align = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let known = Kernel.File.Direct.Requirements.known(align)
        let unknown = Kernel.File.Direct.Requirements.unknown(reason: .platformUnsupported)
        #expect(known != unknown)
    }
}
