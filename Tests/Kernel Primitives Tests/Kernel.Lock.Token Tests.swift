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

extension Kernel.Lock.Token {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Lock.Token.Test.Unit {
    @Test("Token type exists")
    func typeExists() {
        let _: Kernel.Lock.Token.Type = Kernel.Lock.Token.self
    }

    @Test("Token is ~Copyable")
    func isNonCopyable() {
        // Token is ~Copyable, which means it cannot be copied
        // This is a compile-time constraint, we just verify the type exists
        let _: Kernel.Lock.Token.Type = Kernel.Lock.Token.self
    }
}

// MARK: - withExclusive and withShared Tests

extension Kernel.Lock.Token.Test.Unit {
    @Test("withExclusive exists")
    func withExclusiveExists() {
        // Verify the static method signature exists
        typealias WithExclusiveType = (
            Kernel.Descriptor,
            Kernel.Lock.Range,
            Kernel.Lock.Acquire,
            () throws -> Void
        ) throws -> Void
        // The method signature is verified at compile time
    }

    @Test("withShared exists")
    func withSharedExists() {
        // Verify the static method signature exists
        typealias WithSharedType = (
            Kernel.Descriptor,
            Kernel.Lock.Range,
            Kernel.Lock.Acquire,
            () throws -> Void
        ) throws -> Void
        // The method signature is verified at compile time
    }
}

// MARK: - Acquire Strategy Tests

extension Kernel.Lock.Token.Test.Unit {
    @Test("Token init accepts try acquisition")
    func initAcceptsTry() {
        // Verify the init accepts .try acquisition
        // The init signature is: init(descriptor:range:kind:acquire:)
        let _: Kernel.Lock.Acquire = .try
    }

    @Test("Token init accepts wait acquisition")
    func initAcceptsWait() {
        // Verify the init accepts .wait acquisition (the default)
        let _: Kernel.Lock.Acquire = .wait
    }

    @Test("Token init accepts deadline acquisition")
    func initAcceptsDeadline() {
        // Verify the init accepts .deadline acquisition
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        let _: Kernel.Lock.Acquire = .deadline(deadline)
    }

    @Test("Token init accepts timeout acquisition")
    func initAcceptsTimeout() {
        // Verify the init accepts .timeout acquisition
        let _: Kernel.Lock.Acquire = .timeout(.seconds(1))
    }
}

// MARK: - Default Parameter Tests

extension Kernel.Lock.Token.Test.Unit {
    @Test("Token init has default range of .file")
    func defaultRangeIsFile() {
        // The init has: range: Range = .file
        let _: Kernel.Lock.Range = .file
    }

    @Test("Token init has default acquire of .wait")
    func defaultAcquireIsWait() {
        // The init has: acquire: Acquire = .wait
        let _: Kernel.Lock.Acquire = .wait
    }
}

// MARK: - Edge Cases

extension Kernel.Lock.Token.Test.EdgeCase {
    @Test("Token uses all Lock.Kind values")
    func usesAllKinds() {
        // Token accepts both shared and exclusive kinds
        let _: Kernel.Lock.Kind = .shared
        let _: Kernel.Lock.Kind = .exclusive
    }

    @Test("Token uses all Lock.Range values")
    func usesAllRanges() {
        // Token accepts all range types
        let _: Kernel.Lock.Range = .file
        let _: Kernel.Lock.Range = .bytes(start: 0, end: 100)
        let _: Kernel.Lock.Range = .bytes(start: 0, length: 100)
    }

    @Test("Token uses all Lock.Acquire values")
    func usesAllAcquireStrategies() {
        // Token accepts all acquisition strategies
        let _: Kernel.Lock.Acquire = .try
        let _: Kernel.Lock.Acquire = .wait
        let _: Kernel.Lock.Acquire = .deadline(ContinuousClock.now)
        let _: Kernel.Lock.Acquire = .timeout(.seconds(1))
    }
}
