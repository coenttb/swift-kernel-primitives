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

extension Kernel.Memory.Map {
    #TestSuites
}

// MARK: - Map Tests

#if !os(Windows)

    extension Kernel.Memory.Map.Test.Unit {
        @Test("anonymous map succeeds")
        func anonymousMapSucceeds() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            #expect(region.base != .null)
            #expect(region.length == pageSize)
        }

        @Test("map and unmap cycle works")
        func mapAndUnmapCycleWorks() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)

            // Unmap should succeed
            try Kernel.Memory.Map.unmap(region)

            // Note: Accessing the memory after unmap is undefined behavior,
            // so we can't easily verify the unmap worked other than no error.
        }

        @Test("mapped memory is readable and writable")
        func mappedMemoryReadableWritable() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(
                length: pageSize,
                protection: .readWrite
            )
            defer { try? Kernel.Memory.Map.unmap(region) }

            // Write to the mapped memory
            region.withUnsafeMutableBytes { buffer in
                buffer[0] = 42
                buffer[1] = 123
            }

            // Read back
            region.withUnsafeBytes { buffer in
                #expect(buffer[0] == 42)
                #expect(buffer[1] == 123)
            }
        }

        @Test("sync succeeds on mapped region")
        func syncSucceeds() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            // Sync should succeed (even for anonymous, it's a no-op but shouldn't error)
            try Kernel.Memory.Map.sync(addr: region.base, length: region.length)
        }

        @Test("protect changes memory protection")
        func protectChangesProtection() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(
                length: pageSize,
                protection: .readWrite
            )
            defer { try? Kernel.Memory.Map.unmap(region) }

            // Write some data first
            region.withUnsafeMutableBytes { buffer in
                buffer[0] = 99
            }

            // Change to read-only (should succeed)
            try Kernel.Memory.Map.protect(
                addr: region.base,
                length: region.length,
                protection: .read
            )

            // Reading should still work
            region.withUnsafeBytes { buffer in
                #expect(buffer[0] == 99)
            }

            // Note: Writing would now cause SIGBUS/SIGSEGV, which we can't test safely
        }

        @Test("advise does not throw")
        func adviseDoesNotThrow() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            // advise is advisory-only and shouldn't throw
            Kernel.Memory.Map.advise(
                addr: region.base,
                length: region.length,
                advice: .normal
            )
        }

        @Test("multi-page mapping works")
        func multiPageMappingWorks() throws {
            let multiPageSize = Kernel.File.Size(pages: 4)
            let region = try Kernel.Memory.Map.Anonymous.map(length: multiPageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            #expect(region.length == multiPageSize)

            // Write to first and last page
            region.withUnsafeMutableBytes { buffer in
                buffer[0] = 1
                buffer[buffer.count - 1] = 255
            }

            region.withUnsafeBytes { buffer in
                #expect(buffer[0] == 1)
                #expect(buffer[buffer.count - 1] == 255)
            }
        }

        @Test("Region struct stores base and length")
        func regionStructStoresValues() throws {
            let pageSize = Kernel.File.Size.page
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            // Verify region fields
            #expect(region.base != .null)
            #expect(region.length == pageSize)
        }
    }

    // MARK: - Error Tests

    extension Kernel.Memory.Map.Test.EdgeCase {
        @Test("map with zero length throws")
        func mapWithZeroLengthThrows() {
            #expect(throws: Kernel.Memory.Map.Error.self) {
                _ = try Kernel.Memory.Map.Anonymous.map(length: .zero)
            }
        }

        @Test("map with zero length throws invalid length error")
        func mapWithZeroLengthThrowsInvalidLength() {
            do {
                _ = try Kernel.Memory.Map.Anonymous.map(length: .zero)
                Issue.record("Expected error to be thrown")
            } catch {
                if case .invalid(.length) = error {
                    // Expected
                } else {
                    Issue.record("Expected .invalid(.length), got \(error)")
                }
            }
        }
    }

#endif
