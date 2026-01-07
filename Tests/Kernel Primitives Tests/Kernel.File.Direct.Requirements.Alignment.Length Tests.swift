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

extension Kernel.File.Direct.Requirements.Alignment.Length {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Requirements.Alignment.Length.Test.Unit {
    @Test("Length type exists")
    func typeExists() {
        let _: Kernel.File.Direct.Requirements.Alignment.Length.Type =
            Kernel.File.Direct.Requirements.Alignment.Length.self
    }

    @Test("isValid method exists")
    func isValidMethodExists() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let length = alignment.length
        _ = length.isValid(Kernel.File.Size(0))
    }

    @Test("isValid returns true for valid lengths")
    func isValidTrue() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let length = alignment.length
        #expect(length.isValid(Kernel.File.Size(0)) == true)
        #expect(length.isValid(Kernel.File.Size(4096)) == true)
        #expect(length.isValid(Kernel.File.Size(8192)) == true)
        #expect(length.isValid(Kernel.File.Size(16384)) == true)
    }

    @Test("isValid returns false for invalid lengths")
    func isValidFalse() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let length = alignment.length
        #expect(length.isValid(Kernel.File.Size(1)) == false)
        #expect(length.isValid(Kernel.File.Size(100)) == false)
        #expect(length.isValid(Kernel.File.Size(4097)) == false)
        #expect(length.isValid(Kernel.File.Size(5000)) == false)
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Requirements.Alignment.Length.Test.Unit {
    @Test("Length is Sendable")
    func isSendable() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let length: any Sendable = alignment.length
        #expect(length is Kernel.File.Direct.Requirements.Alignment.Length)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Requirements.Alignment.Length.Test.EdgeCase {
    @Test("length accessor returns consistent value")
    func lengthAccessorConsistent() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let length1 = alignment.length
        let length2 = alignment.length
        #expect(length1.isValid(Kernel.File.Size(4096)) == length2.isValid(Kernel.File.Size(4096)))
    }

    @Test("zero length is always valid")
    func zeroAlwaysValid() {
        let alignments: [Binary.Alignment] = [.`512`, .`1024`, .`4096`, .`8192`]
        for value in alignments {
            let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: value)
            #expect(alignment.length.isValid(Kernel.File.Size(0)) == true)
        }
    }

    @Test("alignment value is always valid length")
    func alignmentValueValid() {
        let alignments: [(Binary.Alignment, Kernel.File.Size)] = [
            (.`512`, Kernel.File.Size(512)),
            (.`1024`, Kernel.File.Size(1024)),
            (.`4096`, Kernel.File.Size(4096)),
            (.`8192`, Kernel.File.Size(8192)),
        ]
        for (align, value) in alignments {
            let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: align)
            #expect(alignment.length.isValid(value) == true)
        }
    }
}
