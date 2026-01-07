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

extension Kernel.Lock.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Lock.Error.Test.Unit {
    @Test("contention case exists")
    func contentionCase() {
        let error = Kernel.Lock.Error.contention
        if case .contention = error {
            // Expected
        } else {
            Issue.record("Expected .contention case")
        }
    }

    @Test("deadlock case exists")
    func deadlockCase() {
        let error = Kernel.Lock.Error.deadlock
        if case .deadlock = error {
            // Expected
        } else {
            Issue.record("Expected .deadlock case")
        }
    }

    @Test("unavailable case exists")
    func unavailableCase() {
        let error = Kernel.Lock.Error.unavailable
        if case .unavailable = error {
            // Expected
        } else {
            Issue.record("Expected .unavailable case")
        }
    }
}

// MARK: - Static Properties Tests

extension Kernel.Lock.Error.Test.Unit {
    @Test("timedOut equals contention")
    func timedOutEqualsContention() {
        #expect(Kernel.Lock.Error.timedOut == Kernel.Lock.Error.contention)
    }

    @Test("wouldBlock equals contention")
    func wouldBlockEqualsContention() {
        #expect(Kernel.Lock.Error.wouldBlock == Kernel.Lock.Error.contention)
    }

    @Test("timedOut and wouldBlock are equal")
    func timedOutWouldBlockEqual() {
        #expect(Kernel.Lock.Error.timedOut == Kernel.Lock.Error.wouldBlock)
    }
}

// MARK: - Description Tests

extension Kernel.Lock.Error.Test.Unit {
    @Test("contention description")
    func contentionDescription() {
        let error = Kernel.Lock.Error.contention
        #expect(error.description == "lock contention")
    }

    @Test("deadlock description")
    func deadlockDescription() {
        let error = Kernel.Lock.Error.deadlock
        #expect(error.description == "deadlock detected")
    }

    @Test("unavailable description")
    func unavailableDescription() {
        let error = Kernel.Lock.Error.unavailable
        #expect(error.description == "no locks available")
    }
}

// MARK: - Conformance Tests

extension Kernel.Lock.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.Lock.Error.contention
        #expect(error is Kernel.Lock.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.Lock.Error.contention
        #expect(error is Kernel.Lock.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.Lock.Error.contention
        let b = Kernel.Lock.Error.contention
        let c = Kernel.Lock.Error.deadlock
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Error is Hashable")
    func isHashable() {
        var set = Set<Kernel.Lock.Error>()
        set.insert(.contention)
        set.insert(.deadlock)
        set.insert(.unavailable)
        set.insert(.contention)  // duplicate
        #expect(set.count == 3)
    }

    @Test("Error is CustomStringConvertible")
    func isCustomStringConvertible() {
        let error: any CustomStringConvertible = Kernel.Lock.Error.contention
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Edge Cases

extension Kernel.Lock.Error.Test.EdgeCase {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.Lock.Error] = [
            .contention,
            .deadlock,
            .unavailable,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test("all descriptions are non-empty")
    func allDescriptionsNonEmpty() {
        let cases: [Kernel.Lock.Error] = [
            .contention,
            .deadlock,
            .unavailable,
        ]

        for error in cases {
            #expect(!error.description.isEmpty)
        }
    }

    @Test("all descriptions are unique")
    func allDescriptionsUnique() {
        let descriptions = [
            Kernel.Lock.Error.contention.description,
            Kernel.Lock.Error.deadlock.description,
            Kernel.Lock.Error.unavailable.description,
        ]

        let unique = Set(descriptions)
        #expect(unique.count == descriptions.count)
    }

    @Test("hash values for different errors are different")
    func hashValuesDistinct() {
        let contentionHash = Kernel.Lock.Error.contention.hashValue
        let deadlockHash = Kernel.Lock.Error.deadlock.hashValue
        let unavailableHash = Kernel.Lock.Error.unavailable.hashValue

        // Hash values should generally be different for different cases
        // (not guaranteed but highly likely)
        #expect(contentionHash != deadlockHash || deadlockHash != unavailableHash)
    }
}
