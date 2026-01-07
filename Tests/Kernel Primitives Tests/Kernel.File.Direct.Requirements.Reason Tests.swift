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

extension Kernel.File.Direct.Requirements.Reason {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Requirements.Reason.Test.Unit {
    @Test("platformUnsupported case exists")
    func platformUnsupportedCase() {
        let reason = Kernel.File.Direct.Requirements.Reason.platformUnsupported
        if case .platformUnsupported = reason {
            // Expected
        } else {
            Issue.record("Expected .platformUnsupported case")
        }
    }

    @Test("sectorSizeUndetermined case exists")
    func sectorSizeUndeterminedCase() {
        let reason = Kernel.File.Direct.Requirements.Reason.sectorSizeUndetermined
        if case .sectorSizeUndetermined = reason {
            // Expected
        } else {
            Issue.record("Expected .sectorSizeUndetermined case")
        }
    }

    @Test("filesystemUnsupported case exists")
    func filesystemUnsupportedCase() {
        let reason = Kernel.File.Direct.Requirements.Reason.filesystemUnsupported
        if case .filesystemUnsupported = reason {
            // Expected
        } else {
            Issue.record("Expected .filesystemUnsupported case")
        }
    }

    @Test("invalidHandle case exists")
    func invalidHandleCase() {
        let reason = Kernel.File.Direct.Requirements.Reason.invalidHandle
        if case .invalidHandle = reason {
            // Expected
        } else {
            Issue.record("Expected .invalidHandle case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.File.Direct.Requirements.Reason.Test.Unit {
    @Test("platformUnsupported description")
    func platformUnsupportedDescription() {
        let reason = Kernel.File.Direct.Requirements.Reason.platformUnsupported
        #expect(reason.description == "Platform does not support strict Direct I/O")
    }

    @Test("sectorSizeUndetermined description")
    func sectorSizeUndeterminedDescription() {
        let reason = Kernel.File.Direct.Requirements.Reason.sectorSizeUndetermined
        #expect(reason.description == "Could not determine sector size")
    }

    @Test("filesystemUnsupported description")
    func filesystemUnsupportedDescription() {
        let reason = Kernel.File.Direct.Requirements.Reason.filesystemUnsupported
        #expect(reason.description == "Filesystem does not support Direct I/O")
    }

    @Test("invalidHandle description")
    func invalidHandleDescription() {
        let reason = Kernel.File.Direct.Requirements.Reason.invalidHandle
        #expect(reason.description == "Invalid file handle")
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Requirements.Reason.Test.Unit {
    @Test("Reason is Sendable")
    func isSendable() {
        let reason: any Sendable = Kernel.File.Direct.Requirements.Reason.platformUnsupported
        #expect(reason is Kernel.File.Direct.Requirements.Reason)
    }

    @Test("Reason is Equatable")
    func isEquatable() {
        let a = Kernel.File.Direct.Requirements.Reason.platformUnsupported
        let b = Kernel.File.Direct.Requirements.Reason.platformUnsupported
        let c = Kernel.File.Direct.Requirements.Reason.sectorSizeUndetermined
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Reason is CustomStringConvertible")
    func isCustomStringConvertible() {
        let reason: any CustomStringConvertible = Kernel.File.Direct.Requirements.Reason.platformUnsupported
        #expect(!reason.description.isEmpty)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Requirements.Reason.Test.EdgeCase {
    @Test("all reasons are distinct")
    func allReasonsDistinct() {
        let reasons: [Kernel.File.Direct.Requirements.Reason] = [
            .platformUnsupported,
            .sectorSizeUndetermined,
            .filesystemUnsupported,
            .invalidHandle,
        ]

        for i in 0..<reasons.count {
            for j in (i + 1)..<reasons.count {
                #expect(reasons[i] != reasons[j])
            }
        }
    }

    @Test("all descriptions are distinct")
    func allDescriptionsDistinct() {
        let descriptions = [
            Kernel.File.Direct.Requirements.Reason.platformUnsupported.description,
            Kernel.File.Direct.Requirements.Reason.sectorSizeUndetermined.description,
            Kernel.File.Direct.Requirements.Reason.filesystemUnsupported.description,
            Kernel.File.Direct.Requirements.Reason.invalidHandle.description,
        ]

        let uniqueDescriptions = Set(descriptions)
        #expect(uniqueDescriptions.count == descriptions.count)
    }

    @Test("all descriptions are non-empty")
    func allDescriptionsNonEmpty() {
        let reasons: [Kernel.File.Direct.Requirements.Reason] = [
            .platformUnsupported,
            .sectorSizeUndetermined,
            .filesystemUnsupported,
            .invalidHandle,
        ]

        for reason in reasons {
            #expect(!reason.description.isEmpty)
        }
    }
}
