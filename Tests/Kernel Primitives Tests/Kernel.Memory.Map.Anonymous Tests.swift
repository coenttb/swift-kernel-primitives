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

extension Kernel.Memory.Map.Anonymous {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Memory.Map.Anonymous.Test.Unit {
    @Test("Anonymous namespace exists")
    func namespaceExists() {
        _ = Kernel.Memory.Map.Anonymous.self
    }

    @Test("Anonymous is an enum")
    func isEnum() {
        let _: Kernel.Memory.Map.Anonymous.Type = Kernel.Memory.Map.Anonymous.self
    }
}

// MARK: - Functional Tests

#if !os(Windows)
    extension Kernel.Memory.Map.Anonymous.Test.Unit {
        @Test("map creates a valid region")
        func mapCreatesRegion() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            #expect(region.base != .null)
            #expect(region.length == pageSize)
        }

        @Test("map with custom protection")
        func mapWithCustomProtection() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(
                length: pageSize,
                protection: .read
            )
            defer { try? Kernel.Memory.Map.unmap(region) }

            #expect(region.base != .null)
        }

        @Test("map private by default")
        func mapPrivateByDefault() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            // Should succeed (private is default)
            #expect(region.base != .null)
        }

        @Test("map shared when specified")
        func mapSharedWhenSpecified() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(
                length: pageSize,
                shared: true
            )
            defer { try? Kernel.Memory.Map.unmap(region) }

            #expect(region.base != .null)
        }
    }
#endif

// MARK: - Windows Tests

#if os(Windows)
    extension Kernel.Memory.Map.Anonymous.Test.Unit {
        @Test("map creates a valid region on Windows")
        func mapCreatesRegionWindows() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            #expect(region.base != nil)
            #expect(region.length == pageSize)
        }
    }
#endif
