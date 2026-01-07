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

// Kernel.Event.ID is a typealias to Tagged<Kernel.Event, UInt>
// #TestSuites cannot be used on typealiases

@Suite("Kernel.Event.ID Tests")
struct EventIDTests {

    // MARK: - Basic Initialization

    @Test("ID can be created from UInt literal")
    func literalInit() {
        let id: Kernel.Event.ID = 42
        #expect(id == 42)
    }

    @Test("ID zero is valid")
    func zeroValue() {
        let id: Kernel.Event.ID = 0
        #expect(id == 0)
    }

    @Test("ID max value")
    func maxValue() {
        let id = Kernel.Event.ID(UInt.max)
        #expect(id.rawValue == UInt.max)
    }

    // MARK: - Descriptor Conversion

    @Test("ID from descriptor")
    func fromDescriptor() {
        #if os(Windows)
            // Windows uses HANDLE
        #else
            let descriptor = Kernel.Descriptor(rawValue: 5)
            let id = Kernel.Event.ID(descriptor: descriptor)
            #expect(id == 5)
        #endif
    }

    @Test("Descriptor from ID roundtrip")
    func descriptorRoundtrip() {
        #if os(Windows)
            // Windows uses HANDLE
        #else
            let descriptor = Kernel.Descriptor(rawValue: 10)
            let id = Kernel.Event.ID(descriptor: descriptor)
            let recovered = Kernel.Descriptor(id)
            #expect(recovered?.rawValue == 10)
        #endif
    }

    @Test("Descriptor from ID fails for large values")
    func descriptorFromLargeIDFails() {
        #if !os(Windows)
            // Values larger than Int32.max cannot be converted to a descriptor
            let largeID = Kernel.Event.ID(UInt(Int32.max) + 1)
            let descriptor = Kernel.Descriptor(largeID)
            #expect(descriptor == nil)
        #endif
    }

    // MARK: - Int32 Conversion

    @Test("ID from Int32")
    func fromInt32() {
        let id = Kernel.Event.ID(Int32(15))
        #expect(id == 15)
    }

    @Test("ID from negative Int32")
    func fromNegativeInt32() {
        // Negative values wrap around as unsigned
        let id = Kernel.Event.ID(Int32(-1))
        #expect(id.rawValue == UInt(bitPattern: -1))
    }

    // MARK: - Socket Conversion

    @Test("ID from socket descriptor")
    func fromSocketDescriptor() {
        #if os(Windows)
            // Windows sockets use SOCKET type
        #else
            let socket = Kernel.Socket.Descriptor(rawValue: 7)
            let id = Kernel.Event.ID(socket: socket)
            #expect(id == 7)
        #endif
    }

    // MARK: - Conformances

    @Test("ID is Equatable")
    func isEquatable() {
        let a: Kernel.Event.ID = 42
        let b: Kernel.Event.ID = 42
        let c: Kernel.Event.ID = 43
        #expect(a == b)
        #expect(a != c)
    }

    @Test("ID is Hashable")
    func isHashable() {
        var set = Set<Kernel.Event.ID>()
        set.insert(1)
        set.insert(2)
        set.insert(1)  // duplicate
        #expect(set.count == 2)
    }

    @Test("ID is Sendable")
    func isSendable() {
        let id: any Sendable = Kernel.Event.ID(42)
        #expect(id is Kernel.Event.ID)
    }

    @Test("ID is Comparable")
    func isComparable() {
        let a: Kernel.Event.ID = 10
        let b: Kernel.Event.ID = 20
        #expect(a < b)
        #expect(b > a)
    }
}
