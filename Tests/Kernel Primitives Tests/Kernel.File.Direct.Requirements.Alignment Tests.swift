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

extension Kernel.File.Direct.Requirements.Alignment {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Requirements.Alignment.Test.Unit {
    @Test("init with explicit values")
    func initExplicit() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`512`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`512`
        )
        #expect(alignment.bufferAlignment == .`512`)
        #expect(alignment.offsetAlignment == .`4096`)
        #expect(alignment.lengthMultiple == .`512`)
    }

    @Test("init with uniform alignment")
    func initUniform() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        #expect(alignment.bufferAlignment == .`4096`)
        #expect(alignment.offsetAlignment == .`4096`)
        #expect(alignment.lengthMultiple == .`4096`)
    }

    @Test("bufferAlignment property")
    func bufferAlignmentProperty() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`512`)
        #expect(alignment.bufferAlignment == .`512`)
    }

    @Test("offsetAlignment property")
    func offsetAlignmentProperty() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        #expect(alignment.offsetAlignment == .`4096`)
    }

    @Test("lengthMultiple property")
    func lengthMultipleProperty() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        #expect(alignment.lengthMultiple == .`4096`)
    }
}

// MARK: - Accessor Tests

extension Kernel.File.Direct.Requirements.Alignment.Test.Unit {
    @Test("buffer accessor exists")
    func bufferAccessor() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let _ = alignment.buffer
    }

    @Test("offset accessor exists")
    func offsetAccessor() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let _ = alignment.offset
    }

    @Test("length accessor exists")
    func lengthAccessor() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let _ = alignment.length
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Requirements.Alignment.Test.Unit {
    @Test("Alignment is Sendable")
    func isSendable() {
        let alignment: any Sendable = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        #expect(alignment is Kernel.File.Direct.Requirements.Alignment)
    }

    @Test("Alignment is Equatable")
    func isEquatable() {
        let a = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let b = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let c = Kernel.File.Direct.Requirements.Alignment(uniform: .`512`)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Requirements.Alignment.Test.EdgeCase {
    @Test("alignments with different buffer values are distinct")
    func bufferDistinct() {
        let a = Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`512`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`4096`
        )
        let b = Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`4096`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`4096`
        )
        #expect(a != b)
    }

    @Test("alignments with different offset values are distinct")
    func offsetDistinct() {
        let a = Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`4096`,
            offsetAlignment: .`512`,
            lengthMultiple: .`4096`
        )
        let b = Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`4096`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`4096`
        )
        #expect(a != b)
    }

    @Test("alignments with different length values are distinct")
    func lengthDistinct() {
        let a = Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`4096`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`512`
        )
        let b = Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`4096`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`4096`
        )
        #expect(a != b)
    }

    @Test("uniform alignment equals explicit with same values")
    func uniformEqualsExplicit() {
        let uniform = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let explicit = Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`4096`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`4096`
        )
        #expect(uniform == explicit)
    }
}
