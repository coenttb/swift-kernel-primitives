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

extension Kernel.File.Direct.Capability {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Capability.Test.Unit {
    @Test("directSupported case exists")
    func directSupportedCase() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let capability = Kernel.File.Direct.Capability.directSupported(alignment)
        if case .directSupported = capability {
            // Expected
        } else {
            Issue.record("Expected .directSupported case")
        }
    }

    @Test("uncachedOnly case exists")
    func uncachedOnlyCase() {
        let capability = Kernel.File.Direct.Capability.uncachedOnly
        if case .uncachedOnly = capability {
            // Expected
        } else {
            Issue.record("Expected .uncachedOnly case")
        }
    }

    @Test("bufferedOnly case exists")
    func bufferedOnlyCase() {
        let capability = Kernel.File.Direct.Capability.bufferedOnly
        if case .bufferedOnly = capability {
            // Expected
        } else {
            Issue.record("Expected .bufferedOnly case")
        }
    }
}

// MARK: - Accessor Tests

extension Kernel.File.Direct.Capability.Test.Unit {
    @Test("direct.isSupported returns true for directSupported")
    func directIsSupportedTrue() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let capability = Kernel.File.Direct.Capability.directSupported(alignment)
        #expect(capability.direct.isSupported == true)
    }

    @Test("direct.isSupported returns false for uncachedOnly")
    func directIsSupportedFalseUncached() {
        let capability = Kernel.File.Direct.Capability.uncachedOnly
        #expect(capability.direct.isSupported == false)
    }

    @Test("direct.isSupported returns false for bufferedOnly")
    func directIsSupportedFalseBuffered() {
        let capability = Kernel.File.Direct.Capability.bufferedOnly
        #expect(capability.direct.isSupported == false)
    }

    @Test("bypass.isSupported returns true for directSupported")
    func bypassIsSupportedDirect() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let capability = Kernel.File.Direct.Capability.directSupported(alignment)
        #expect(capability.bypass.isSupported == true)
    }

    @Test("bypass.isSupported returns true for uncachedOnly")
    func bypassIsSupportedUncached() {
        let capability = Kernel.File.Direct.Capability.uncachedOnly
        #expect(capability.bypass.isSupported == true)
    }

    @Test("bypass.isSupported returns false for bufferedOnly")
    func bypassIsSupportedFalseBuffered() {
        let capability = Kernel.File.Direct.Capability.bufferedOnly
        #expect(capability.bypass.isSupported == false)
    }

    @Test("alignment returns value for directSupported")
    func alignmentForDirectSupported() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let capability = Kernel.File.Direct.Capability.directSupported(alignment)
        #expect(capability.alignment != nil)
        #expect(capability.alignment?.bufferAlignment == .`4096`)
    }

    @Test("alignment returns nil for uncachedOnly")
    func alignmentNilForUncached() {
        let capability = Kernel.File.Direct.Capability.uncachedOnly
        #expect(capability.alignment == nil)
    }

    @Test("alignment returns nil for bufferedOnly")
    func alignmentNilForBuffered() {
        let capability = Kernel.File.Direct.Capability.bufferedOnly
        #expect(capability.alignment == nil)
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Capability.Test.Unit {
    @Test("Capability is Sendable")
    func isSendable() {
        let capability: any Sendable = Kernel.File.Direct.Capability.uncachedOnly
        #expect(capability is Kernel.File.Direct.Capability)
    }

    @Test("Capability is Equatable")
    func isEquatable() {
        let a = Kernel.File.Direct.Capability.uncachedOnly
        let b = Kernel.File.Direct.Capability.uncachedOnly
        let c = Kernel.File.Direct.Capability.bufferedOnly
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Capability.Test.EdgeCase {
    @Test("all simple cases are distinct")
    func simpleCasesDistinct() {
        let uncached = Kernel.File.Direct.Capability.uncachedOnly
        let buffered = Kernel.File.Direct.Capability.bufferedOnly
        #expect(uncached != buffered)
    }

    @Test("directSupported with different alignments are distinct")
    func directSupportedDistinct() {
        let align1 = Kernel.File.Direct.Requirements.Alignment(uniform: .`512`)
        let align2 = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let cap1 = Kernel.File.Direct.Capability.directSupported(align1)
        let cap2 = Kernel.File.Direct.Capability.directSupported(align2)
        #expect(cap1 != cap2)
    }
}
