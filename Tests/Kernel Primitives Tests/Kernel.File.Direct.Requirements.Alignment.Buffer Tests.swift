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

extension Kernel.File.Direct.Requirements.Alignment.Buffer {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Requirements.Alignment.Buffer.Test.Unit {
    @Test("Buffer type exists")
    func typeExists() {
        let _: Kernel.File.Direct.Requirements.Alignment.Buffer.Type =
            Kernel.File.Direct.Requirements.Alignment.Buffer.self
    }

    @Test("isAligned method exists")
    func isAlignedMethodExists() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let buffer = alignment.buffer
        let bytes = [UInt8](repeating: 0, count: 4096)
        bytes.withUnsafeBytes { pointer in
            _ = buffer.isAligned(Kernel.Memory.Address(pointer.baseAddress!))
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Requirements.Alignment.Buffer.Test.Unit {
    @Test("Buffer is Sendable")
    func isSendable() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let buffer: any Sendable = alignment.buffer
        #expect(buffer is Kernel.File.Direct.Requirements.Alignment.Buffer)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Requirements.Alignment.Buffer.Test.EdgeCase {
    @Test("buffer accessor returns consistent value")
    func bufferAccessorConsistent() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let buffer1 = alignment.buffer
        let buffer2 = alignment.buffer
        // Both should work identically
        let bytes = [UInt8](repeating: 0, count: 4096)
        bytes.withUnsafeBytes { pointer in
            let addr = Kernel.Memory.Address(pointer.baseAddress!)
            let result1 = buffer1.isAligned(addr)
            let result2 = buffer2.isAligned(addr)
            #expect(result1 == result2)
        }
    }
}
