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

extension Kernel.IO.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.IO.Error.Test.Unit {
    @Test("broken case exists")
    func brokenCase() {
        let error = Kernel.IO.Error.broken
        if case .broken = error {
            // Expected
        } else {
            Issue.record("Expected .broken case")
        }
    }

    @Test("reset case exists")
    func resetCase() {
        let error = Kernel.IO.Error.reset
        if case .reset = error {
            // Expected
        } else {
            Issue.record("Expected .reset case")
        }
    }

    @Test("hardware case exists")
    func hardwareCase() {
        let error = Kernel.IO.Error.hardware
        if case .hardware = error {
            // Expected
        } else {
            Issue.record("Expected .hardware case")
        }
    }

    @Test("illegalSeek case exists")
    func illegalSeekCase() {
        let error = Kernel.IO.Error.illegalSeek
        if case .illegalSeek = error {
            // Expected
        } else {
            Issue.record("Expected .illegalSeek case")
        }
    }

    @Test("deviceUnsupported case exists")
    func deviceUnsupportedCase() {
        let error = Kernel.IO.Error.deviceUnsupported
        if case .deviceUnsupported = error {
            // Expected
        } else {
            Issue.record("Expected .deviceUnsupported case")
        }
    }

    @Test("deviceUnavailable case exists")
    func deviceUnavailableCase() {
        let error = Kernel.IO.Error.deviceUnavailable
        if case .deviceUnavailable = error {
            // Expected
        } else {
            Issue.record("Expected .deviceUnavailable case")
        }
    }

    @Test("unsupported case exists")
    func unsupportedCase() {
        let error = Kernel.IO.Error.unsupported
        if case .unsupported = error {
            // Expected
        } else {
            Issue.record("Expected .unsupported case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.IO.Error.Test.Unit {
    @Test("broken description")
    func brokenDescription() {
        #expect(Kernel.IO.Error.broken.description == "broken pipe")
    }

    @Test("reset description")
    func resetDescription() {
        #expect(Kernel.IO.Error.reset.description == "connection reset")
    }

    @Test("hardware description")
    func hardwareDescription() {
        #expect(Kernel.IO.Error.hardware.description == "I/O error")
    }

    @Test("illegalSeek description")
    func illegalSeekDescription() {
        #expect(Kernel.IO.Error.illegalSeek.description == "illegal seek")
    }

    @Test("deviceUnsupported description")
    func deviceUnsupportedDescription() {
        #expect(Kernel.IO.Error.deviceUnsupported.description == "operation not supported by device")
    }

    @Test("deviceUnavailable description")
    func deviceUnavailableDescription() {
        #expect(Kernel.IO.Error.deviceUnavailable.description == "device unavailable")
    }

    @Test("unsupported description")
    func unsupportedDescription() {
        #expect(Kernel.IO.Error.unsupported.description == "operation not supported")
    }
}

// MARK: - Conformance Tests

extension Kernel.IO.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.IO.Error.broken
        #expect(error is Kernel.IO.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.IO.Error.broken
        #expect(error is Kernel.IO.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        #expect(Kernel.IO.Error.broken == .broken)
        #expect(Kernel.IO.Error.broken != .reset)
        #expect(Kernel.IO.Error.hardware != .illegalSeek)
    }

    @Test("Error is Hashable")
    func isHashable() {
        var set = Set<Kernel.IO.Error>()
        set.insert(.broken)
        set.insert(.reset)
        set.insert(.hardware)
        set.insert(.broken)  // duplicate
        #expect(set.count == 3)
    }
}

// MARK: - Edge Cases

extension Kernel.IO.Error.Test.EdgeCase {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.IO.Error] = [
            .broken, .reset, .hardware, .illegalSeek,
            .deviceUnsupported, .deviceUnavailable, .unsupported,
        ]

        // Verify all pairs are distinct
        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j], "Cases \(cases[i]) and \(cases[j]) should be distinct")
            }
        }
    }

    @Test("all cases have unique descriptions")
    func allDescriptionsUnique() {
        let descriptions = [
            Kernel.IO.Error.broken.description,
            Kernel.IO.Error.reset.description,
            Kernel.IO.Error.hardware.description,
            Kernel.IO.Error.illegalSeek.description,
            Kernel.IO.Error.deviceUnsupported.description,
            Kernel.IO.Error.deviceUnavailable.description,
            Kernel.IO.Error.unsupported.description,
        ]
        let uniqueDescriptions = Set(descriptions)
        #expect(uniqueDescriptions.count == descriptions.count, "All descriptions should be unique")
    }
}
