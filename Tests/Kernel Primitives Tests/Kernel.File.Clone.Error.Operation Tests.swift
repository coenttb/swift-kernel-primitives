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

extension Kernel.File.Clone.Error.Operation {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Clone.Error.Operation.Test.Unit {
    @Test("clonefile case exists")
    func clonefileCase() {
        let operation = Kernel.File.Clone.Error.Operation.clonefile
        #expect(operation.rawValue == "clonefile")
    }

    @Test("copyfile case exists")
    func copyfileCase() {
        let operation = Kernel.File.Clone.Error.Operation.copyfile
        #expect(operation.rawValue == "copyfile")
    }

    @Test("ficlone case exists")
    func ficloneCase() {
        let operation = Kernel.File.Clone.Error.Operation.ficlone
        #expect(operation.rawValue == "ficlone")
    }

    @Test("copyFileRange case exists")
    func copyFileRangeCase() {
        let operation = Kernel.File.Clone.Error.Operation.copyFileRange
        #expect(operation.rawValue == "copyFileRange")
    }

    @Test("duplicateExtents case exists")
    func duplicateExtentsCase() {
        let operation = Kernel.File.Clone.Error.Operation.duplicateExtents
        #expect(operation.rawValue == "duplicateExtents")
    }

    @Test("statfs case exists")
    func statfsCase() {
        let operation = Kernel.File.Clone.Error.Operation.statfs
        #expect(operation.rawValue == "statfs")
    }

    @Test("stat case exists")
    func statCase() {
        let operation = Kernel.File.Clone.Error.Operation.stat
        #expect(operation.rawValue == "stat")
    }

    @Test("copy case exists")
    func copyCase() {
        let operation = Kernel.File.Clone.Error.Operation.copy
        #expect(operation.rawValue == "copy")
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Clone.Error.Operation.Test.Unit {
    @Test("Operation is Sendable")
    func isSendable() {
        let operation: any Sendable = Kernel.File.Clone.Error.Operation.clonefile
        #expect(operation is Kernel.File.Clone.Error.Operation)
    }

    @Test("Operation is Equatable")
    func isEquatable() {
        let a = Kernel.File.Clone.Error.Operation.clonefile
        let b = Kernel.File.Clone.Error.Operation.clonefile
        let c = Kernel.File.Clone.Error.Operation.copyfile
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Operation is RawRepresentable")
    func isRawRepresentable() {
        let operation = Kernel.File.Clone.Error.Operation.clonefile
        let fromRaw = Kernel.File.Clone.Error.Operation(rawValue: "clonefile")
        #expect(fromRaw == operation)
    }

    @Test("Operation is Hashable")
    func isHashable() {
        var set = Set<Kernel.File.Clone.Error.Operation>()
        set.insert(.clonefile)
        set.insert(.copyfile)
        set.insert(.clonefile)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Clone.Error.Operation.Test.EdgeCase {
    @Test("all operations are distinct")
    func allOperationsDistinct() {
        let operations: [Kernel.File.Clone.Error.Operation] = [
            .clonefile,
            .copyfile,
            .ficlone,
            .copyFileRange,
            .duplicateExtents,
            .statfs,
            .stat,
            .copy,
        ]

        for i in 0..<operations.count {
            for j in (i + 1)..<operations.count {
                #expect(operations[i] != operations[j])
            }
        }
    }

    @Test("all raw values are distinct")
    func allRawValuesDistinct() {
        let rawValues = [
            Kernel.File.Clone.Error.Operation.clonefile.rawValue,
            Kernel.File.Clone.Error.Operation.copyfile.rawValue,
            Kernel.File.Clone.Error.Operation.ficlone.rawValue,
            Kernel.File.Clone.Error.Operation.copyFileRange.rawValue,
            Kernel.File.Clone.Error.Operation.duplicateExtents.rawValue,
            Kernel.File.Clone.Error.Operation.statfs.rawValue,
            Kernel.File.Clone.Error.Operation.stat.rawValue,
            Kernel.File.Clone.Error.Operation.copy.rawValue,
        ]

        let uniqueRawValues = Set(rawValues)
        #expect(uniqueRawValues.count == rawValues.count)
    }

    @Test("invalid raw value returns nil")
    func invalidRawValue() {
        let operation = Kernel.File.Clone.Error.Operation(rawValue: "invalid")
        #expect(operation == nil)
    }
}
