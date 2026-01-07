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

import Kernel_Test_Support
import StandardsTestSupport
import Testing

@testable import Kernel_Primitives

extension Kernel.IO.Read {
    #TestSuites
}

// MARK: - Read Tests

#if !os(Windows)

    extension Kernel.IO.Read.Test.Unit {
        @Test("read returns bytes from file")
        func readReturnsBytesFromFile() throws {
            let (path, fd) = try KernelIOTest.createTempFileWithContent("Hello, World!", prefix: "read-test")
            defer { KernelIOTest.cleanupTempFile(path: path, fd: fd) }

            // Seek to start
            _ = try Kernel.Seek.toStart(fd)

            var buffer = [UInt8](repeating: 0, count: 13)
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try Kernel.IO.Read.read(fd, into: ptr)
            }

            #expect(bytesRead == 13)
            #expect(String(decoding: buffer, as: UTF8.self) == "Hello, World!")
        }

        @Test("read returns 0 on EOF")
        func readReturnsZeroOnEOF() throws {
            let (path, fd) = try KernelIOTest.createTempFileWithContent("Hi", prefix: "read-test")
            defer { KernelIOTest.cleanupTempFile(path: path, fd: fd) }

            // Seek to start and read all content
            _ = try Kernel.Seek.toStart(fd)
            var buffer = [UInt8](repeating: 0, count: 10)
            _ = try buffer.withUnsafeMutableBytes { ptr in
                try Kernel.IO.Read.read(fd, into: ptr)
            }

            // Now at EOF, next read should return 0
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try Kernel.IO.Read.read(fd, into: ptr)
            }

            #expect(bytesRead == 0)
        }

        @Test("read with empty buffer returns 0")
        func readWithEmptyBufferReturnsZero() throws {
            let (path, fd) = try KernelIOTest.createTempFileWithContent("content", prefix: "read-test")
            defer { KernelIOTest.cleanupTempFile(path: path, fd: fd) }

            let emptyBuffer = UnsafeMutableRawBufferPointer(start: nil, count: 0)
            let bytesRead = try Kernel.IO.Read.read(fd, into: emptyBuffer)

            #expect(bytesRead == 0)
        }

        @Test("read partial buffer")
        func readPartialBuffer() throws {
            let (path, fd) = try KernelIOTest.createTempFileWithContent("Short", prefix: "read-test")
            defer { KernelIOTest.cleanupTempFile(path: path, fd: fd) }

            _ = try Kernel.Seek.toStart(fd)

            // Request more bytes than available
            var buffer = [UInt8](repeating: 0, count: 100)
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try Kernel.IO.Read.read(fd, into: ptr)
            }

            #expect(bytesRead == 5)
            #expect(String(decoding: buffer.prefix(5), as: UTF8.self) == "Short")
        }

        @Test("pread reads at offset without changing position")
        func preadReadsAtOffset() throws {
            let (path, fd) = try KernelIOTest.createTempFileWithContent("0123456789", prefix: "read-test")
            defer { KernelIOTest.cleanupTempFile(path: path, fd: fd) }

            // Record initial position
            let initialPos = try Kernel.Seek.toCurrent(fd)

            // Read 3 bytes starting at offset 5
            var buffer = [UInt8](repeating: 0, count: 3)
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try Kernel.IO.Read.pread(fd, into: ptr, at: Kernel.File.Offset(5))
            }

            #expect(bytesRead == 3)
            #expect(String(decoding: buffer, as: UTF8.self) == "567")

            // Position should be unchanged
            let finalPos = try Kernel.Seek.toCurrent(fd)
            #expect(finalPos == initialPos)
        }

        @Test("pread at end of file returns 0")
        func preadAtEOFReturnsZero() throws {
            let (path, fd) = try KernelIOTest.createTempFileWithContent("data", prefix: "read-test")
            defer { KernelIOTest.cleanupTempFile(path: path, fd: fd) }

            var buffer = [UInt8](repeating: 0, count: 10)
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try Kernel.IO.Read.pread(fd, into: ptr, at: Kernel.File.Offset(100))
            }

            #expect(bytesRead == 0)
        }

        @Test("pread with empty buffer returns 0")
        func preadWithEmptyBufferReturnsZero() throws {
            let (path, fd) = try KernelIOTest.createTempFileWithContent("content", prefix: "read-test")
            defer { KernelIOTest.cleanupTempFile(path: path, fd: fd) }

            let emptyBuffer = UnsafeMutableRawBufferPointer(start: nil, count: 0)
            let bytesRead = try Kernel.IO.Read.pread(fd, into: emptyBuffer, at: Kernel.File.Offset(0))

            #expect(bytesRead == 0)
        }
    }

    // MARK: - Error Tests

    extension Kernel.IO.Read.Test.EdgeCase {
        @Test("read throws on invalid descriptor")
        func readThrowsOnInvalidDescriptor() {
            let invalidFd = Kernel.Descriptor(rawValue: -1)
            var buffer = [UInt8](repeating: 0, count: 10)

            #expect(throws: Kernel.IO.Read.Error.self) {
                try buffer.withUnsafeMutableBytes { ptr in
                    try Kernel.IO.Read.read(invalidFd, into: ptr)
                }
            }
        }

        @Test("pread throws on invalid descriptor")
        func preadThrowsOnInvalidDescriptor() {
            let invalidFd = Kernel.Descriptor(rawValue: -1)
            var buffer = [UInt8](repeating: 0, count: 10)

            #expect(throws: Kernel.IO.Read.Error.self) {
                try buffer.withUnsafeMutableBytes { ptr in
                    try Kernel.IO.Read.pread(invalidFd, into: ptr, at: Kernel.File.Offset(0))
                }
            }
        }
    }

#endif
