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

extension Kernel.Device {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Device.Test.Unit {
    @Test("Device type exists")
    func typeExists() {
        let _: Kernel.Device.Type = Kernel.Device.self
    }

    @Test("Device from rawValue")
    func fromRawValue() {
        let device = Kernel.Device(rawValue: 42)
        #expect(device.rawValue == 42)
    }

    @Test("Device from UInt64")
    func fromUInt64() {
        let device = Kernel.Device(100)
        #expect(device.rawValue == 100)
    }
}

// MARK: - ExpressibleByIntegerLiteral Tests

extension Kernel.Device.Test.Unit {
    @Test("Device from integer literal")
    func fromIntegerLiteral() {
        let device: Kernel.Device = 256
        #expect(device.rawValue == 256)
    }
}

// MARK: - Conformance Tests

extension Kernel.Device.Test.Unit {
    @Test("Device is Sendable")
    func isSendable() {
        let value: any Sendable = Kernel.Device(0)
        #expect(value is Kernel.Device)
    }

    @Test("Device is Equatable")
    func isEquatable() {
        let a = Kernel.Device(100)
        let b = Kernel.Device(100)
        let c = Kernel.Device(200)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Device is Hashable")
    func isHashable() {
        var set = Set<Kernel.Device>()
        set.insert(Kernel.Device(1))
        set.insert(Kernel.Device(2))
        set.insert(Kernel.Device(1))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Major/Minor Tests (POSIX only)

#if !os(Windows)
    extension Kernel.Device.Test.Unit {
        @Test("Device major/minor extraction")
        func majorMinorExtraction() {
            // Create a device with known major/minor
            let device = Kernel.Device(major: 8, minor: 1)
            #expect(device.major == 8)
            #expect(device.minor == 1)
        }

        @Test("Device major/minor roundtrip")
        func majorMinorRoundtrip() {
            let major: UInt32 = 253
            let minor: UInt32 = 42
            let device = Kernel.Device(major: major, minor: minor)
            #expect(device.major == major)
            #expect(device.minor == minor)
        }
    }
#endif

// MARK: - CustomStringConvertible Tests

extension Kernel.Device.Test.Unit {
    @Test("Device description is not empty")
    func descriptionNotEmpty() {
        let device = Kernel.Device(100)
        #expect(!device.description.isEmpty)
    }

    #if !os(Windows)
        @Test("Device description contains colon")
        func descriptionContainsColon() {
            let device = Kernel.Device(major: 8, minor: 1)
            #expect(device.description.contains(":"))
        }
    #endif
}

// MARK: - Edge Cases

extension Kernel.Device.Test.EdgeCase {
    @Test("Device zero")
    func zeroDevice() {
        let device = Kernel.Device(0)
        #expect(device.rawValue == 0)
    }

    @Test("Device max value")
    func maxValue() {
        let device = Kernel.Device(UInt64.max)
        #expect(device.rawValue == UInt64.max)
    }

    @Test("Device rawValue roundtrip")
    func rawValueRoundtrip() {
        for value: UInt64 in [0, 1, 100, 0xDEAD_BEEF, UInt64.max] {
            let device = Kernel.Device(rawValue: value)
            #expect(device.rawValue == value)
        }
    }
}
