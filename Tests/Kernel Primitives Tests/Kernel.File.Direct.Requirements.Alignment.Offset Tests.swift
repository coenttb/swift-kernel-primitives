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

extension Kernel.File.Direct.Requirements.Alignment.Offset {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Requirements.Alignment.Offset.Test.Unit {
    @Test("Offset type exists")
    func typeExists() {
        let _: Kernel.File.Direct.Requirements.Alignment.Offset.Type =
            Kernel.File.Direct.Requirements.Alignment.Offset.self
    }

    @Test("isAligned method exists")
    func isAlignedMethodExists() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let offset = alignment.offset
        _ = offset.isAligned(0)
    }

    @Test("isAligned returns true for aligned offset")
    func isAlignedTrue() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let offset = alignment.offset
        #expect(offset.isAligned(0) == true)
        #expect(offset.isAligned(4096) == true)
        #expect(offset.isAligned(8192) == true)
    }

    @Test("isAligned returns false for unaligned offset")
    func isAlignedFalse() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let offset = alignment.offset
        #expect(offset.isAligned(1) == false)
        #expect(offset.isAligned(100) == false)
        #expect(offset.isAligned(4097) == false)
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Requirements.Alignment.Offset.Test.Unit {
    @Test("Offset is Sendable")
    func isSendable() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let offset: any Sendable = alignment.offset
        #expect(offset is Kernel.File.Direct.Requirements.Alignment.Offset)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Requirements.Alignment.Offset.Test.EdgeCase {
    @Test("offset accessor returns consistent value")
    func offsetAccessorConsistent() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let offset1 = alignment.offset
        let offset2 = alignment.offset
        #expect(offset1.isAligned(4096) == offset2.isAligned(4096))
    }

    @Test("zero offset is always aligned")
    func zeroAlwaysAligned() {
        let alignments: [Binary.Alignment] = [.`512`, .`1024`, .`4096`, .`8192`]
        for value in alignments {
            let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: value)
            #expect(alignment.offset.isAligned(0) == true)
        }
    }
}
