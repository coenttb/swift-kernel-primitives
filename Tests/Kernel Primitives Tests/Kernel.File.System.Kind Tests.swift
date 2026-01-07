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

extension Kernel.File.System.Kind {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.System.Kind.Test.Unit {
    @Test("Kind from rawValue")
    func rawValueInit() {
        let kind = Kernel.File.System.Kind(rawValue: 0x1234)
        #expect(kind.rawValue == 0x1234)
    }

    @Test("Kind from UInt64")
    func uint64Init() {
        let kind = Kernel.File.System.Kind(0xABCD)
        #expect(kind.rawValue == 0xABCD)
    }

    @Test("rawValue roundtrip")
    func rawValueRoundtrip() {
        let original: UInt64 = 0x9123_683E
        let kind = Kernel.File.System.Kind(rawValue: original)
        #expect(kind.rawValue == original)
    }
}

// MARK: - Conformance Tests

extension Kernel.File.System.Kind.Test.Unit {
    @Test("Kind is Sendable")
    func isSendable() {
        let kind: any Sendable = Kernel.File.System.Kind(0x1234)
        #expect(kind is Kernel.File.System.Kind)
    }

    @Test("Kind is Equatable")
    func isEquatable() {
        let a = Kernel.File.System.Kind(0x1234)
        let b = Kernel.File.System.Kind(0x1234)
        let c = Kernel.File.System.Kind(0x5678)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Kind is Hashable")
    func isHashable() {
        var set = Set<Kernel.File.System.Kind>()
        set.insert(Kernel.File.System.Kind(0x1234))
        set.insert(Kernel.File.System.Kind(0x5678))
        set.insert(Kernel.File.System.Kind(0x1234))  // duplicate
        #expect(set.count == 2)
    }

    @Test("Kind is RawRepresentable")
    func isRawRepresentable() {
        let kind = Kernel.File.System.Kind(rawValue: 0x1234)
        let fromRaw = Kernel.File.System.Kind(rawValue: kind.rawValue)
        #expect(kind == fromRaw)
    }

    @Test("Kind is CustomStringConvertible")
    func isCustomStringConvertible() {
        let kind: any CustomStringConvertible = Kernel.File.System.Kind(0x1234)
        #expect(!kind.description.isEmpty)
    }
}

// MARK: - Linux-specific Tests

#if os(Linux)
    extension Kernel.File.System.Kind.Test.Unit {
        @Test("ext4 constant exists")
        func ext4Constant() {
            let kind = Kernel.File.System.Kind.ext4
            #expect(kind.rawValue == 0xEF53)
        }

        @Test("btrfs constant exists")
        func btrfsConstant() {
            let kind = Kernel.File.System.Kind.btrfs
            #expect(kind.rawValue == 0x9123_683E)
        }

        @Test("xfs constant exists")
        func xfsConstant() {
            let kind = Kernel.File.System.Kind.xfs
            #expect(kind.rawValue == 0x5846_5342)
        }

        @Test("tmpfs constant exists")
        func tmpfsConstant() {
            let kind = Kernel.File.System.Kind.tmpfs
            #expect(kind.rawValue == 0x0102_1994)
        }

        @Test("proc constant exists")
        func procConstant() {
            let kind = Kernel.File.System.Kind.proc
            #expect(kind.rawValue == 0x9FA0)
        }

        @Test("sysfs constant exists")
        func sysfsConstant() {
            let kind = Kernel.File.System.Kind.sysfs
            #expect(kind.rawValue == 0x6265_6572)
        }

        @Test("nfs constant exists")
        func nfsConstant() {
            let kind = Kernel.File.System.Kind.nfs
            #expect(kind.rawValue == 0x6969)
        }

        @Test("cifs constant exists")
        func cifsConstant() {
            let kind = Kernel.File.System.Kind.cifs
            #expect(kind.rawValue == 0xFF53_4D42)
        }

        @Test("known filesystems have descriptive names")
        func knownDescriptions() {
            #expect(Kernel.File.System.Kind.ext4.description == "ext4")
            #expect(Kernel.File.System.Kind.btrfs.description == "btrfs")
            #expect(Kernel.File.System.Kind.xfs.description == "xfs")
            #expect(Kernel.File.System.Kind.tmpfs.description == "tmpfs")
        }
    }
#endif

// MARK: - Edge Cases

extension Kernel.File.System.Kind.Test.EdgeCase {
    @Test("zero raw value")
    func zeroRawValue() {
        let kind = Kernel.File.System.Kind(0)
        #expect(kind.rawValue == 0)
    }

    @Test("maximum raw value")
    func maxRawValue() {
        let kind = Kernel.File.System.Kind(UInt64.max)
        #expect(kind.rawValue == UInt64.max)
    }

    @Test("different raw values are distinct")
    func differentRawValuesDistinct() {
        let kind1 = Kernel.File.System.Kind(0x1234)
        let kind2 = Kernel.File.System.Kind(0x5678)
        #expect(kind1 != kind2)
    }
}
