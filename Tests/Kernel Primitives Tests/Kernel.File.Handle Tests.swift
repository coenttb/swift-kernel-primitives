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
import Kernel_Primitives_Test_Support
import StandardsTestSupport
import Testing

@testable import Kernel_Primitives

extension Kernel.File.Handle {
    #TestSuites
}

// MARK: - Handle Tests

#if !os(Windows)

    extension Kernel.File.Handle.Test.Unit {
        @Test("init stores descriptor and mode")
        func initStoresDescriptorAndMode() throws {
            try KernelIOTest.withTempFileForHandle(prefix: "handle-test") { _, fd in
                let handle = Kernel.File.Handle(
                    descriptor: fd,
                    direct: .buffered,
                    requirements: .unknown(reason: .platformUnsupported)
                )

                #expect(handle.direct == .buffered)

                // Handle will close on deinit
                _ = consume handle
            }
        }

        @Test("read returns bytes from file")
        func readReturnsBytesFromFile() throws {
            try KernelIOTest.withTempFileForHandle(content: "TestData", prefix: "handle-test") { _, fd in
                let handle = Kernel.File.Handle(
                    descriptor: fd,
                    direct: .buffered,
                    requirements: .unknown(reason: .platformUnsupported)
                )

                var buffer = [UInt8](repeating: 0, count: 8)
                let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                    try handle.read(into: ptr, at: Kernel.File.Offset(0))
                }

                #expect(bytesRead == 8)
                #expect(String(decoding: buffer, as: UTF8.self) == "TestData")

                _ = consume handle
            }
        }

        @Test("write writes bytes to file")
        func writeWritesBytesToFile() throws {
            try KernelIOTest.withTempFileForHandle(prefix: "handle-test") { _, fd in
                let handle = Kernel.File.Handle(
                    descriptor: fd,
                    direct: .buffered,
                    requirements: .unknown(reason: .platformUnsupported)
                )

                let content = Array("Written".utf8)
                let bytesWritten = try content.withUnsafeBytes { ptr in
                    try handle.write(from: ptr, at: Kernel.File.Offset(0))
                }

                #expect(bytesWritten == 7)

                // Verify by reading back
                var buffer = [UInt8](repeating: 0, count: 7)
                _ = try buffer.withUnsafeMutableBytes { ptr in
                    try handle.read(into: ptr, at: Kernel.File.Offset(0))
                }
                #expect(String(decoding: buffer, as: UTF8.self) == "Written")

                _ = consume handle
            }
        }

        @Test("close explicitly closes handle")
        func closeExplicitlyClosesHandle() throws {
            try KernelIOTest.withTempFileForHandle(prefix: "handle-test") { _, fd in
                var handle = Kernel.File.Handle(
                    descriptor: fd,
                    direct: .buffered,
                    requirements: .unknown(reason: .platformUnsupported)
                )

                try handle.close()

                // Second close should be no-op (idempotent)
                try handle.close()

                _ = consume handle
            }
        }

        @Test("withDescriptor provides access to raw descriptor")
        func withDescriptorProvidesAccess() throws {
            try KernelIOTest.withTempFileForHandle(prefix: "handle-test") { _, fd in
                let handle = Kernel.File.Handle(
                    descriptor: fd,
                    direct: .buffered,
                    requirements: .unknown(reason: .platformUnsupported)
                )

                let rawValue = handle.withDescriptor { descriptor in
                    descriptor.rawValue
                }

                #expect(rawValue == fd.rawValue)

                _ = consume handle
            }
        }

        @Test("handle closes on deinit")
        func handleClosesOnDeinit() throws {
            try KernelIOTest.withTempFileForHandle(prefix: "handle-test") { _, fd in
                // Create and immediately drop handle
                do {
                    let handle = Kernel.File.Handle(
                        descriptor: fd,
                        direct: .buffered,
                        requirements: .unknown(reason: .platformUnsupported)
                    )
                    _ = consume handle
                }

                // After deinit, descriptor should be closed
                // Attempting to use it should fail
                var buffer = [UInt8](repeating: 0, count: 1)
                do {
                    _ = try buffer.withUnsafeMutableBytes { ptr in
                        try Kernel.IO.Read.read(fd, into: ptr)
                    }
                    Issue.record("Read on closed descriptor should fail")
                } catch {
                    // Expected - descriptor is closed
                }
            }
        }
    }

    // MARK: - Direct Mode Tests

    extension Kernel.File.Handle.Test.Unit {
        @Test("direct mode enum is equatable")
        func directModeEquatable() {
            #expect(Kernel.File.Direct.Mode.Resolved.buffered == .buffered)
            #expect(Kernel.File.Direct.Mode.Resolved.direct == .direct)
            #expect(Kernel.File.Direct.Mode.Resolved.uncached == .uncached)
            #expect(Kernel.File.Direct.Mode.Resolved.buffered != .direct)
        }

        @Test("requirements known case")
        func requirementsKnownCase() {
            let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
            let requirements = Kernel.File.Direct.Requirements.known(alignment)

            if case .known(let a) = requirements {
                #expect(a.bufferAlignment == .`4096`)
            } else {
                Issue.record("Expected .known case")
            }
        }

        @Test("requirements unknown case")
        func requirementsUnknownCase() {
            let requirements = Kernel.File.Direct.Requirements.unknown(reason: .platformUnsupported)

            if case .unknown(let reason) = requirements {
                #expect(reason == .platformUnsupported)
            } else {
                Issue.record("Expected .unknown case")
            }
        }
    }

#endif
