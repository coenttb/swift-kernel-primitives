// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import StandardsTestSupport
import Testing

@testable import Kernel_Primitives

extension Kernel.Time {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Time.Test.Unit {
    @Test("init with seconds and nanoseconds")
    func initWithSecondsAndNanoseconds() {
        let time = Kernel.Time(seconds: 1_234_567_890, nanoseconds: 123_456_789)
        #expect(time.seconds == 1_234_567_890)
        #expect(time.nanoseconds == 123_456_789)
    }

    @Test("init with seconds only")
    func initWithSecondsOnly() {
        let time = Kernel.Time(seconds: 1_234_567_890)
        #expect(time.seconds == 1_234_567_890)
        #expect(time.nanoseconds == 0)
    }

    @Test("Time is Sendable")
    func isSendable() {
        let time: any Sendable = Kernel.Time(seconds: 0)
        #expect(time is Kernel.Time)
    }

    @Test("Time is Equatable")
    func isEquatable() {
        let a = Kernel.Time(seconds: 100, nanoseconds: 500)
        let b = Kernel.Time(seconds: 100, nanoseconds: 500)
        let c = Kernel.Time(seconds: 100, nanoseconds: 501)

        #expect(a == b)
        #expect(a != c)
    }

    @Test("Time is Hashable")
    func isHashable() {
        let a = Kernel.Time(seconds: 100, nanoseconds: 500)
        let b = Kernel.Time(seconds: 100, nanoseconds: 500)

        #expect(a.hashValue == b.hashValue)
    }

    @Test("Time is Comparable")
    func isComparable() {
        let earlier = Kernel.Time(seconds: 100, nanoseconds: 0)
        let later = Kernel.Time(seconds: 100, nanoseconds: 1)
        let muchLater = Kernel.Time(seconds: 101, nanoseconds: 0)

        #expect(earlier < later)
        #expect(later < muchLater)
        #expect(earlier < muchLater)
    }
}

// MARK: - Edge Cases

extension Kernel.Time.Test.EdgeCase {
    @Test("zero time")
    func zeroTime() {
        let time = Kernel.Time(seconds: 0, nanoseconds: 0)
        #expect(time.seconds == 0)
        #expect(time.nanoseconds == 0)
    }

    @Test("negative seconds")
    func negativeSeconds() {
        let time = Kernel.Time(seconds: -1, nanoseconds: 0)
        #expect(time.seconds == -1)
    }

    @Test("maximum nanoseconds")
    func maxNanoseconds() {
        let time = Kernel.Time(seconds: 0, nanoseconds: 999_999_999)
        #expect(time.nanoseconds == 999_999_999)
    }

    @Test("comparison with equal seconds different nanoseconds")
    func comparisonNanoseconds() {
        let a = Kernel.Time(seconds: 100, nanoseconds: 0)
        let b = Kernel.Time(seconds: 100, nanoseconds: 999_999_999)

        #expect(a < b)
        #expect(!(b < a))
    }
}
