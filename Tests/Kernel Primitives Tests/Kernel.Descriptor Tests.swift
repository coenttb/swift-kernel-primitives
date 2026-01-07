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

extension Kernel.Descriptor {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Descriptor.Test.Unit {
    @Test("invalid descriptor has correct raw value on POSIX")
    func invalidDescriptorValue() {
        #if !os(Windows)
            #expect(Kernel.Descriptor.invalid.rawValue == -1)
        #endif
    }

    @Test("isValid returns false for invalid descriptor")
    func isValidFalseForInvalid() {
        #expect(!Kernel.Descriptor.invalid.isValid)
    }

    @Test("isValid returns true for valid descriptor")
    func isValidTrueForValid() {
        #if !os(Windows)
            // Standard input (0), stdout (1), stderr (2) are always valid
            #expect(Kernel.Descriptor(rawValue: 0).isValid)
            #expect(Kernel.Descriptor(rawValue: 1).isValid)
            #expect(Kernel.Descriptor(rawValue: 2).isValid)
        #endif
    }

    @Test("RawRepresentable roundtrip preserves value")
    func rawRepresentableRoundtrip() {
        #if !os(Windows)
            let original = Kernel.Descriptor(rawValue: 42)
            let reconstructed = Kernel.Descriptor(rawValue: original.rawValue)
            #expect(original == reconstructed)
            #expect(original.rawValue == 42)
        #endif
    }

    @Test("Descriptor is Equatable")
    func descriptorIsEquatable() {
        #if !os(Windows)
            let a = Kernel.Descriptor(rawValue: 5)
            let b = Kernel.Descriptor(rawValue: 5)
            let c = Kernel.Descriptor(rawValue: 10)

            #expect(a == b)
            #expect(a != c)
        #endif
    }

    @Test("Descriptor is Hashable")
    func descriptorIsHashable() {
        #if !os(Windows)
            var set = Set<Kernel.Descriptor>()
            set.insert(Kernel.Descriptor(rawValue: 1))
            set.insert(Kernel.Descriptor(rawValue: 2))
            set.insert(Kernel.Descriptor(rawValue: 1))  // duplicate

            #expect(set.count == 2)
        #endif
    }

    @Test("Descriptor works in Dictionary")
    func descriptorInDictionary() {
        #if !os(Windows)
            var dict = [Kernel.Descriptor: String]()
            dict[Kernel.Descriptor(rawValue: 0)] = "stdin"
            dict[Kernel.Descriptor(rawValue: 1)] = "stdout"
            dict[Kernel.Descriptor(rawValue: 2)] = "stderr"

            #expect(dict[Kernel.Descriptor(rawValue: 0)] == "stdin")
            #expect(dict[Kernel.Descriptor(rawValue: 1)] == "stdout")
            #expect(dict[Kernel.Descriptor(rawValue: 2)] == "stderr")
            #expect(dict.count == 3)
        #endif
    }

    @Test("negative descriptors are invalid on POSIX")
    func negativeDescriptorsInvalid() {
        #if !os(Windows)
            #expect(!Kernel.Descriptor(rawValue: -1).isValid)
            #expect(!Kernel.Descriptor(rawValue: -100).isValid)
            #expect(!Kernel.Descriptor(rawValue: Int32.min).isValid)
        #endif
    }
}
