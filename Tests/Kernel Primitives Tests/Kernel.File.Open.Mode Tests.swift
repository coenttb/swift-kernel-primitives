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

extension Kernel.File.Open.Mode {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Open.Mode.Test.Unit {
    @Test("Mode from rawValue")
    func rawValueInit() {
        let mode = Kernel.File.Open.Mode(rawValue: 1)
        #expect(mode.rawValue == 1)
    }

    @Test("read constant")
    func readConstant() {
        let mode = Kernel.File.Open.Mode.read
        #expect(mode.rawValue == 1 << 0)
    }

    @Test("write constant")
    func writeConstant() {
        let mode = Kernel.File.Open.Mode.write
        #expect(mode.rawValue == 1 << 1)
    }
}

// MARK: - OptionSet Operations

extension Kernel.File.Open.Mode.Test.Unit {
    @Test("read and write can be combined")
    func readWrite() {
        let mode: Kernel.File.Open.Mode = [.read, .write]
        #expect(mode.contains(.read))
        #expect(mode.contains(.write))
    }

    @Test("contains check for read")
    func containsRead() {
        let mode: Kernel.File.Open.Mode = [.read]
        #expect(mode.contains(.read))
        #expect(!mode.contains(.write))
    }

    @Test("contains check for write")
    func containsWrite() {
        let mode: Kernel.File.Open.Mode = [.write]
        #expect(!mode.contains(.read))
        #expect(mode.contains(.write))
    }

    @Test("empty mode")
    func emptyMode() {
        let mode = Kernel.File.Open.Mode()
        #expect(!mode.contains(.read))
        #expect(!mode.contains(.write))
    }
}

// MARK: - POSIX Conversion Tests

#if !os(Windows)
    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    extension Kernel.File.Open.Mode.Test.Unit {
        @Test("read mode converts to O_RDONLY")
        func readPosixFlags() {
            let mode: Kernel.File.Open.Mode = [.read]
            #expect(mode.posixFlags == O_RDONLY)
        }

        @Test("write mode converts to O_WRONLY")
        func writePosixFlags() {
            let mode: Kernel.File.Open.Mode = [.write]
            #expect(mode.posixFlags == O_WRONLY)
        }

        @Test("read/write mode converts to O_RDWR")
        func readWritePosixFlags() {
            let mode: Kernel.File.Open.Mode = [.read, .write]
            #expect(mode.posixFlags == O_RDWR)
        }

        @Test("empty mode defaults to O_RDONLY")
        func emptyPosixFlags() {
            let mode = Kernel.File.Open.Mode()
            #expect(mode.posixFlags == O_RDONLY)
        }
    }
#endif

// MARK: - Conformances

extension Kernel.File.Open.Mode.Test.Unit {
    @Test("Mode is Sendable")
    func isSendable() {
        let mode: any Sendable = Kernel.File.Open.Mode.read
        #expect(mode is Kernel.File.Open.Mode)
    }

    @Test("Mode is Equatable")
    func isEquatable() {
        let a: Kernel.File.Open.Mode = [.read]
        let b: Kernel.File.Open.Mode = [.read]
        let c: Kernel.File.Open.Mode = [.write]
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Mode is Hashable")
    func isHashable() {
        var set = Set<Kernel.File.Open.Mode>()
        set.insert([.read])
        set.insert([.write])
        set.insert([.read])  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Open.Mode.Test.EdgeCase {
    @Test("read and write are distinct bits")
    func distinctBits() {
        let read = Kernel.File.Open.Mode.read
        let write = Kernel.File.Open.Mode.write
        #expect(read.rawValue & write.rawValue == 0)
    }

    @Test("combined mode rawValue")
    func combinedRawValue() {
        let combined: Kernel.File.Open.Mode = [.read, .write]
        #expect(combined.rawValue == (1 << 0) | (1 << 1))
    }
}
