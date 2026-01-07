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

extension Kernel.File.System.Block {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.System.Block.Test.Unit {
    @Test("Block namespace exists")
    func namespaceExists() {
        _ = Kernel.File.System.Block.self
    }

    @Test("Block is an enum")
    func isEnum() {
        let _: Kernel.File.System.Block.Type = Kernel.File.System.Block.self
    }
}

// MARK: - Nested Types

extension Kernel.File.System.Block.Test.Unit {
    @Test("Block.Size type exists")
    func sizeTypeExists() {
        let _: Kernel.File.System.Block.Size.Type = Kernel.File.System.Block.Size.self
    }

    @Test("Block.Count type exists")
    func countTypeExists() {
        let _: Kernel.File.System.Block.Count.Type = Kernel.File.System.Block.Count.self
    }
}

// MARK: - Size Tests

extension Kernel.File.System.Block.Test.Unit {
    @Test("Size from UInt64")
    func sizeUInt64Init() {
        let size = Kernel.File.System.Block.Size(512)
        #expect(size == 512)
    }

    @Test("Size sector512 constant")
    func sizeSector512() {
        let size = Kernel.File.System.Block.Size.sector512
        #expect(size == 512)
    }

    @Test("Size page4096 constant")
    func sizePage4096() {
        let size = Kernel.File.System.Block.Size.page4096
        #expect(size == 4096)
    }

    @Test("Size is Comparable")
    func sizeIsComparable() {
        let small = Kernel.File.System.Block.Size(512)
        let large = Kernel.File.System.Block.Size(4096)
        #expect(small < large)
        #expect(large > small)
    }

    @Test("Size is ExpressibleByIntegerLiteral")
    func sizeIntegerLiteral() {
        let size: Kernel.File.System.Block.Size = 8192
        #expect(size == 8192)
    }

    @Test("Size is Sendable")
    func sizeIsSendable() {
        let size: any Sendable = Kernel.File.System.Block.Size(4096)
        #expect(size is Kernel.File.System.Block.Size)
    }

    @Test("Size is Equatable")
    func sizeIsEquatable() {
        let a = Kernel.File.System.Block.Size(4096)
        let b = Kernel.File.System.Block.Size(4096)
        let c = Kernel.File.System.Block.Size(512)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Size is Hashable")
    func sizeIsHashable() {
        var set = Set<Kernel.File.System.Block.Size>()
        set.insert(Kernel.File.System.Block.Size(512))
        set.insert(Kernel.File.System.Block.Size(4096))
        set.insert(Kernel.File.System.Block.Size(512))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Count Tests

extension Kernel.File.System.Block.Test.Unit {
    @Test("Count zero constant")
    func countZero() {
        let count = Kernel.File.System.Block.Count.zero
        #expect(count == 0)
    }

    @Test("Count addition")
    func countAddition() {
        let a = Kernel.File.System.Block.Count(100)
        let b = Kernel.File.System.Block.Count(50)
        let sum = a + b
        #expect(sum == 150)
    }

    @Test("Count subtraction")
    func countSubtraction() {
        let a = Kernel.File.System.Block.Count(100)
        let b = Kernel.File.System.Block.Count(30)
        let diff = a - b
        #expect(diff == 70)
    }
}

// MARK: - Edge Cases

extension Kernel.File.System.Block.Test.EdgeCase {
    @Test("Size zero value")
    func sizeZero() {
        let size = Kernel.File.System.Block.Size(0)
        #expect(size == 0)
    }

    @Test("Size maximum value")
    func sizeMax() {
        let size = Kernel.File.System.Block.Size(UInt64.max)
        #expect(size.rawValue == UInt64.max)
    }

    @Test("Count zero additions")
    func countZeroAddition() {
        let zero = Kernel.File.System.Block.Count.zero
        let hundred = Kernel.File.System.Block.Count(100)
        #expect((zero + hundred) == 100)
        #expect((hundred + zero) == 100)
    }

    @Test("Size ordering consistency")
    func sizeOrdering() {
        let sizes = [
            Kernel.File.System.Block.Size(512),
            Kernel.File.System.Block.Size(1024),
            Kernel.File.System.Block.Size(2048),
            Kernel.File.System.Block.Size(4096),
        ]

        for i in 0..<(sizes.count - 1) {
            #expect(sizes[i] < sizes[i + 1])
        }
    }
}
