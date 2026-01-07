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

extension Kernel.Lock.Range {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Lock.Range.Test.Unit {
    @Test("file case exists")
    func fileCase() {
        let range = Kernel.Lock.Range.file
        if case .file = range {
            // Expected
        } else {
            Issue.record("Expected .file case")
        }
    }

    @Test("bytes case exists with start and end")
    func bytesCase() {
        let start = Kernel.File.Offset(100)
        let end = Kernel.File.Offset(200)
        let range = Kernel.Lock.Range.bytes(start: start, end: end)
        if case .bytes(let s, let e) = range {
            #expect(s == start)
            #expect(e == end)
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test("bytes factory with start and length")
    func bytesFactoryWithLength() {
        let start = Kernel.File.Offset(100)
        let length = Kernel.File.Size(50)
        let range = Kernel.Lock.Range.bytes(start: start, length: length)
        if case .bytes(let s, let e) = range {
            #expect(s == start)
            #expect(e == start + length)
        } else {
            Issue.record("Expected .bytes case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Lock.Range.Test.Unit {
    @Test("Range is Sendable")
    func isSendable() {
        let range: any Sendable = Kernel.Lock.Range.file
        #expect(range is Kernel.Lock.Range)
    }

    @Test("Range is Equatable")
    func isEquatable() {
        let a = Kernel.Lock.Range.file
        let b = Kernel.Lock.Range.file
        let c = Kernel.Lock.Range.bytes(start: 0, end: 100)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Range is Hashable")
    func isHashable() {
        var set = Set<Kernel.Lock.Range>()
        set.insert(.file)
        set.insert(.bytes(start: 0, end: 100))
        set.insert(.bytes(start: 100, end: 200))
        set.insert(.file)  // duplicate
        #expect(set.count == 3)
    }
}

// MARK: - Bytes Range Tests

extension Kernel.Lock.Range.Test.Unit {
    @Test("bytes ranges with same values are equal")
    func bytesEquality() {
        let a = Kernel.Lock.Range.bytes(start: 100, end: 200)
        let b = Kernel.Lock.Range.bytes(start: 100, end: 200)
        #expect(a == b)
    }

    @Test("bytes ranges with different starts are distinct")
    func bytesDifferentStart() {
        let a = Kernel.Lock.Range.bytes(start: 100, end: 200)
        let b = Kernel.Lock.Range.bytes(start: 150, end: 200)
        #expect(a != b)
    }

    @Test("bytes ranges with different ends are distinct")
    func bytesDifferentEnd() {
        let a = Kernel.Lock.Range.bytes(start: 100, end: 200)
        let b = Kernel.Lock.Range.bytes(start: 100, end: 250)
        #expect(a != b)
    }

    @Test("bytes factory produces correct end offset")
    func bytesFactoryCorrectEnd() {
        let range = Kernel.Lock.Range.bytes(start: 1000, length: 500)
        if case .bytes(_, let end) = range {
            #expect(end == Kernel.File.Offset(1500))
        } else {
            Issue.record("Expected .bytes case")
        }
    }
}

// MARK: - Edge Cases

extension Kernel.Lock.Range.Test.EdgeCase {
    @Test("file and bytes are distinct")
    func fileBytesDist() {
        let file = Kernel.Lock.Range.file
        let bytes = Kernel.Lock.Range.bytes(start: 0, end: .max)
        #expect(file != bytes)
    }

    @Test("bytes with zero length")
    func zeroLengthBytes() {
        let range = Kernel.Lock.Range.bytes(start: 100, length: 0)
        if case .bytes(let start, let end) = range {
            #expect(start == end)
            #expect(start == Kernel.File.Offset(100))
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test("bytes with zero start")
    func zeroStartBytes() {
        let range = Kernel.Lock.Range.bytes(start: 0, end: 1000)
        if case .bytes(let start, _) = range {
            #expect(start == Kernel.File.Offset(0))
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test("bytes with max end (to EOF)")
    func maxEndBytes() {
        let range = Kernel.Lock.Range.bytes(start: 0, end: .max)
        if case .bytes(_, let end) = range {
            #expect(end == .max)
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test("bytes factory with max length")
    func maxLengthBytes() {
        let range = Kernel.Lock.Range.bytes(start: 0, length: Kernel.File.Size(Kernel.File.Offset.max.rawValue))
        if case .bytes(let start, let end) = range {
            #expect(start == Kernel.File.Offset(0))
            #expect(end == .max)
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test("adjacent ranges are distinct")
    func adjacentRangesDistinct() {
        let a = Kernel.Lock.Range.bytes(start: 0, end: 100)
        let b = Kernel.Lock.Range.bytes(start: 100, end: 200)
        #expect(a != b)
    }
}
