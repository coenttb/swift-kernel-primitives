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

import Binary
import StandardsTestSupport
import Testing

@testable import Kernel_Primitives

// Kernel.Memory.Address is a typealias to Binary.Position<UInt, Space>
// #TestSuites cannot be used on typealiases

@Suite("Kernel.Memory.Address Tests")
struct MemoryAddressTests {

    @Test("Address is a typealias to Binary.Position<UInt, Space>")
    func addressIsTypealias() {
        // The types should be identical
        let _: Kernel.Memory.Address.Type = Binary.Position<UInt, Kernel.Memory.Space>.self
    }

    @Test("Address can be created from pointer")
    func addressFromPointer() {
        // Allocate some memory
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: 8, alignment: 8)
        defer { ptr.deallocate() }

        let address = Kernel.Memory.Address(ptr)

        // Verify we got a valid address (non-null)
        #expect(address != .null)
        #expect(address.mutablePointer == ptr)
    }

    @Test("Address can round-trip through pointer")
    func addressRoundTrip() {
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: 8, alignment: 8)
        defer { ptr.deallocate() }

        let address = Kernel.Memory.Address(ptr)

        // Write a value through the pointer
        address.mutablePointer!.storeBytes(of: UInt64(0xDEAD_BEEF), as: UInt64.self)

        // Read it back
        let value = address.pointer!.load(as: UInt64.self)
        #expect(value == 0xDEAD_BEEF)
    }

    @Test("null constant is zero")
    func nullConstant() {
        #expect(Kernel.Memory.Address.null == 0)
        #expect(Kernel.Memory.Address.null.pointer == nil)
        #expect(Kernel.Memory.Address.null.mutablePointer == nil)
    }
}
