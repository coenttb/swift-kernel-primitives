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

extension Kernel.Memory.Map.Region {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Memory.Map.Region.Test.Unit {
    @Test("Region type exists")
    func typeExists() {
        let _: Kernel.Memory.Map.Region.Type = Kernel.Memory.Map.Region.self
    }

    @Test("Region is @unchecked Sendable")
    func isSendable() {
        // Region contains a raw pointer but is marked @unchecked Sendable
        let _: any Sendable.Type = Kernel.Memory.Map.Region.self
    }
}

// MARK: - Property Tests

#if !os(Windows)
    extension Kernel.Memory.Map.Region.Test.Unit {
        @Test("Region stores base address")
        func storesBase() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            #expect(region.base != .null)
        }

        @Test("Region stores length")
        func storesLength() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            #expect(region.length == pageSize)
        }

        @Test("Region init sets values correctly")
        func initSetsValues() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            // Create a new region with same values
            let copy = Kernel.Memory.Map.Region(base: region.base, length: region.length)
            #expect(copy.base == region.base)
            #expect(copy.length == region.length)
        }
    }
#endif

// MARK: - Windows Tests

#if os(Windows)
    extension Kernel.Memory.Map.Region.Test.Unit {
        @Test("Region stores mappingHandle on Windows")
        func storesMappingHandle() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            // The mapping handle should be set
            #expect(region.mappingHandle != nil)
        }
    }
#endif
