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

// Kernel.File.Offset is a typealias to Coordinate.X<Space>.Value<Int64>
// #TestSuites cannot be used on typealiases

@Suite("Kernel.File.Offset Tests")
struct FileOffsetTests {

    // MARK: - Basic Initialization

    @Test("Offset from integer literal")
    func literalInit() {
        let offset: Kernel.File.Offset = 1000
        #expect(offset == 1000)
    }

    @Test("Offset from Int")
    func intInit() {
        let offset = Kernel.File.Offset(100)
        #expect(offset == 100)
    }

    @Test("Offset from Int64")
    func int64Init() {
        let offset = Kernel.File.Offset(Int64(5000))
        #expect(offset == 5000)
    }

    // MARK: - Constants

    @Test("zero constant")
    func zeroConstant() {
        #expect(Kernel.File.Offset.zero == 0)
    }

    @Test("max constant")
    func maxConstant() {
        #expect(Kernel.File.Offset.max.rawValue == Int64.max)
    }

    // MARK: - Arithmetic with Delta

    @Test("Offset minus Offset equals Delta")
    func offsetMinusOffset() {
        let start: Kernel.File.Offset = 1000
        let end: Kernel.File.Offset = 5000
        let delta = end - start
        #expect(delta == 4000)
    }

    @Test("Offset plus Delta equals Offset")
    func offsetPlusDelta() {
        let offset: Kernel.File.Offset = 1000
        let delta = Kernel.File.Delta(3000)
        let result = offset + delta
        #expect(result == 4000)
    }

    @Test("Offset minus Delta equals Offset")
    func offsetMinusDelta() {
        let offset: Kernel.File.Offset = 5000
        let delta = Kernel.File.Delta(2000)
        let result = offset - delta
        #expect(result == 3000)
    }

    // MARK: - Arithmetic with Size

    @Test("Offset plus Size equals Offset")
    func offsetPlusSize() {
        let offset: Kernel.File.Offset = 1000
        let size: Kernel.File.Size = 4096
        let result = offset + size
        #expect(result == 5096)
    }

    @Test("Offset minus Size equals Offset")
    func offsetMinusSize() {
        let offset: Kernel.File.Offset = 5096
        let size: Kernel.File.Size = 4096
        let result = offset - size
        #expect(result == 1000)
    }

    @Test("Offset plus Size in place")
    func offsetPlusSizeInPlace() {
        var offset: Kernel.File.Offset = 1000
        let size: Kernel.File.Size = 500
        offset += size
        #expect(offset == 1500)
    }

    @Test("Offset minus Size in place")
    func offsetMinusSizeInPlace() {
        var offset: Kernel.File.Offset = 1500
        let size: Kernel.File.Size = 500
        offset -= size
        #expect(offset == 1000)
    }

    // MARK: - Conformances

    @Test("Offset is Equatable")
    func isEquatable() {
        let a: Kernel.File.Offset = 1000
        let b: Kernel.File.Offset = 1000
        let c: Kernel.File.Offset = 2000
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Offset is Hashable")
    func isHashable() {
        var set = Set<Kernel.File.Offset>()
        set.insert(Kernel.File.Offset(1000))
        set.insert(Kernel.File.Offset(2000))
        set.insert(Kernel.File.Offset(1000))  // duplicate
        #expect(set.count == 2)
    }

    @Test("Offset is Sendable")
    func isSendable() {
        let offset: any Sendable = Kernel.File.Offset(1000)
        #expect(offset is Kernel.File.Offset)
    }

    @Test("Offset is Comparable")
    func isComparable() {
        let a: Kernel.File.Offset = 1000
        let b: Kernel.File.Offset = 2000
        #expect(a < b)
        #expect(b > a)
    }
}

// MARK: - Delta Tests

@Suite("Kernel.File.Delta Tests")
struct FileDeltaTests {

    @Test("Delta from integer literal")
    func literalInit() {
        let delta: Kernel.File.Delta = 500
        #expect(delta == 500)
    }

    @Test("Negative Delta")
    func negativeDelta() {
        let delta = Kernel.File.Delta(-100)
        #expect(delta == -100)
    }

    @Test("Delta is Equatable")
    func isEquatable() {
        let a = Kernel.File.Delta(100)
        let b = Kernel.File.Delta(100)
        let c = Kernel.File.Delta(-100)
        #expect(a == b)
        #expect(a != c)
    }
}
