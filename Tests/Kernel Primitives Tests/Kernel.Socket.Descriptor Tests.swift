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

extension Kernel.Socket.Descriptor {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Socket.Descriptor.Test.Unit {
    @Test("Descriptor type exists")
    func typeExists() {
        let _: Kernel.Socket.Descriptor.Type = Kernel.Socket.Descriptor.self
    }

    @Test("Descriptor from rawValue")
    func fromRawValue() {
        #if os(Windows)
            let descriptor = Kernel.Socket.Descriptor(rawValue: 42)
            #expect(descriptor.rawValue == 42)
        #else
            let descriptor = Kernel.Socket.Descriptor(rawValue: 42)
            #expect(descriptor.rawValue == 42)
        #endif
    }

    @Test("Descriptor invalid sentinel")
    func invalidSentinel() {
        let invalid = Kernel.Socket.Descriptor.invalid
        #if os(Windows)
            #expect(invalid.rawValue == UInt64.max)
        #else
            #expect(invalid.rawValue == -1)
        #endif
    }

    @Test("Descriptor isValid for valid descriptor")
    func isValidTrue() {
        let descriptor = Kernel.Socket.Descriptor(rawValue: 3)
        #expect(descriptor.isValid)
    }

    @Test("Descriptor isValid for invalid sentinel")
    func isValidFalse() {
        let invalid = Kernel.Socket.Descriptor.invalid
        #expect(!invalid.isValid)
    }
}

// MARK: - Conformance Tests

extension Kernel.Socket.Descriptor.Test.Unit {
    @Test("Descriptor is Sendable")
    func isSendable() {
        let value: any Sendable = Kernel.Socket.Descriptor(rawValue: 0)
        #expect(value is Kernel.Socket.Descriptor)
    }

    @Test("Descriptor is Equatable")
    func isEquatable() {
        let a = Kernel.Socket.Descriptor(rawValue: 5)
        let b = Kernel.Socket.Descriptor(rawValue: 5)
        let c = Kernel.Socket.Descriptor(rawValue: 10)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Descriptor is Hashable")
    func isHashable() {
        var set = Set<Kernel.Socket.Descriptor>()
        set.insert(Kernel.Socket.Descriptor(rawValue: 1))
        set.insert(Kernel.Socket.Descriptor(rawValue: 2))
        set.insert(Kernel.Socket.Descriptor(rawValue: 1))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Kernel.Descriptor Interop Tests (POSIX only)

#if !os(Windows)
    extension Kernel.Socket.Descriptor.Test.Unit {
        @Test("Descriptor from Kernel.Descriptor")
        func fromKernelDescriptor() {
            let fileDescriptor = Kernel.Descriptor(rawValue: 7)
            let socketDescriptor = Kernel.Socket.Descriptor(fileDescriptor)
            #expect(socketDescriptor.rawValue == 7)
        }

        @Test("Kernel.Descriptor from Socket.Descriptor")
        func toKernelDescriptor() {
            let socketDescriptor = Kernel.Socket.Descriptor(rawValue: 8)
            let fileDescriptor = Kernel.Descriptor(socketDescriptor)
            #expect(fileDescriptor.rawValue == 8)
        }
    }
#endif

// MARK: - Edge Cases

extension Kernel.Socket.Descriptor.Test.EdgeCase {
    #if !os(Windows)
        @Test("Descriptor zero is valid on POSIX")
        func zeroIsValid() {
            let descriptor = Kernel.Socket.Descriptor(rawValue: 0)
            #expect(descriptor.isValid)
        }

        @Test("Descriptor negative is invalid on POSIX")
        func negativeIsInvalid() {
            let descriptor = Kernel.Socket.Descriptor(rawValue: -1)
            #expect(!descriptor.isValid)
        }
    #endif

    @Test("Descriptor rawValue roundtrip")
    func rawValueRoundtrip() {
        #if os(Windows)
            let values: [UInt64] = [0, 1, 100, 1000]
        #else
            let values: [Int32] = [0, 1, 100, 1000]
        #endif
        for value in values {
            let descriptor = Kernel.Socket.Descriptor(rawValue: value)
            #expect(descriptor.rawValue == value)
        }
    }
}
