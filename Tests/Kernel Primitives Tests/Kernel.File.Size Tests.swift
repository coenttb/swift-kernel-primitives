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

// Kernel.File.Size is a typealias to Magnitude<Space>.Value<Int64>
// #TestSuites cannot be used on typealiases

@Suite("Kernel.File.Size Tests")
struct FileSizeTests {

    // MARK: - Basic Initialization

    @Test("Size from integer literal")
    func literalInit() {
        let size: Kernel.File.Size = 4096
        #expect(size == 4096)
    }

    @Test("Size from Int")
    func intInit() {
        let size = Kernel.File.Size(100)
        #expect(size == 100)
    }

    @Test("Size from Int64")
    func int64Init() {
        let size = Kernel.File.Size(Int64(5000))
        #expect(size == 5000)
    }

    @Test("Size from UInt64")
    func uint64Init() {
        let size = Kernel.File.Size(UInt64(8192))
        #expect(size == 8192)
    }

    @Test("Size from pages")
    func pagesInit() {
        let size = Kernel.File.Size(pages: 2)
        let expectedBytes = 2 * Int(Kernel.System.pageSize)
        #expect(size.rawValue == Int64(expectedBytes))
    }

    // MARK: - Constants

    @Test("zero constant")
    func zeroConstant() {
        #expect(Kernel.File.Size.zero == 0)
    }

    @Test("kilobyte constant")
    func kilobyteConstant() {
        #expect(Kernel.File.Size.kilobyte == 1024)
    }

    @Test("megabyte constant")
    func megabyteConstant() {
        #expect(Kernel.File.Size.megabyte.rawValue == 1024 * 1024)
    }

    @Test("gigabyte constant")
    func gigabyteConstant() {
        #expect(Kernel.File.Size.gigabyte.rawValue == 1024 * 1024 * 1024)
    }

    @Test("page constant")
    func pageConstant() {
        let pageSize = Kernel.File.Size.page
        #expect(pageSize.rawValue == Int64(Int(Kernel.System.pageSize)))
    }

    // MARK: - Queries

    @Test("isZero for zero size")
    func isZeroTrue() {
        #expect(Kernel.File.Size.zero.isZero)
    }

    @Test("isZero for non-zero size")
    func isZeroFalse() {
        let size: Kernel.File.Size = 100
        #expect(!size.isZero)
    }

    @Test("isPositive for positive size")
    func isPositiveTrue() {
        let size: Kernel.File.Size = 100
        #expect(size.isPositive)
    }

    @Test("isPositive for zero")
    func isPositiveZero() {
        #expect(!Kernel.File.Size.zero.isPositive)
    }

    // MARK: - Arithmetic

    @Test("Size plus Size")
    func sizePlusSize() {
        let a: Kernel.File.Size = 1000
        let b: Kernel.File.Size = 2000
        let result = a + b
        #expect(result == 3000)
    }

    @Test("Size minus Size")
    func sizeMinusSize() {
        let a: Kernel.File.Size = 3000
        let b: Kernel.File.Size = 1000
        let result = a - b
        #expect(result == 2000)
    }

    // MARK: - Int Conversion

    @Test("Int from Size")
    func intFromSize() {
        let size: Kernel.File.Size = 4096
        let intValue = Int(size)
        #expect(intValue == 4096)
    }

    // MARK: - Conformances

    @Test("Size is Equatable")
    func isEquatable() {
        let a: Kernel.File.Size = 4096
        let b: Kernel.File.Size = 4096
        let c: Kernel.File.Size = 8192
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Size is Hashable")
    func isHashable() {
        var set = Set<Kernel.File.Size>()
        set.insert(Kernel.File.Size(1024))
        set.insert(Kernel.File.Size(2048))
        set.insert(Kernel.File.Size(1024))  // duplicate
        #expect(set.count == 2)
    }

    @Test("Size is Sendable")
    func isSendable() {
        let size: any Sendable = Kernel.File.Size(4096)
        #expect(size is Kernel.File.Size)
    }

    @Test("Size is Comparable")
    func isComparable() {
        let a: Kernel.File.Size = 1024
        let b: Kernel.File.Size = 2048
        #expect(a < b)
        #expect(b > a)
    }
}
