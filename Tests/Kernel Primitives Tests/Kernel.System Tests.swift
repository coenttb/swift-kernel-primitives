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

extension Kernel.System {
    #TestSuites
}

// MARK: - Path Max Unit Tests

extension Kernel.System.Test.Unit {
    @Test("pathMax is positive")
    func pathMaxPositive() {
        #expect(Kernel.System.pathMax > 0)
    }

    @Test("pathMax is reasonable")
    func pathMaxReasonable() {
        // PATH_MAX should be at least 256 on any platform
        #expect(Kernel.System.pathMax >= 256)
        // And not unreasonably large (sanity check)
        #expect(Kernel.System.pathMax <= 65536)
    }

    #if os(macOS)
        @Test("macOS pathMax is 1024")
        func macOSPathMax() {
            #expect(Kernel.System.pathMax == 1024)
        }
    #endif

    #if os(Linux)
        @Test("Linux pathMax is typically 4096")
        func linuxPathMax() {
            #expect(Kernel.System.pathMax == 4096)
        }
    #endif
}

// MARK: - Page Size Unit Tests

extension Kernel.System.Test.Unit {
    @Test("pageSize is positive")
    func pageSizePositive() {
        #expect(Kernel.System.pageSize > 0)
    }

    @Test("pageSize is power of 2")
    func pageSizePowerOfTwo() {
        let size = Int(Kernel.System.pageSize)
        // A power of 2 has exactly one bit set
        #expect(size & (size - 1) == 0)
    }

    @Test("pageSize is at least 4KB")
    func pageSizeMinimum() {
        // Most systems have at least 4KB pages
        #expect(Kernel.System.pageSize >= 4096)
    }

    #if os(macOS) && arch(arm64)
        @Test("pageSize is 16KB on Apple Silicon")
        func pageSizeAppleSilicon() {
            #expect(Kernel.System.pageSize == 16384)
        }
    #endif
}

// MARK: - Allocation Granularity Unit Tests

extension Kernel.System.Test.Unit {
    @Test("allocationGranularity is positive")
    func allocationGranularityPositive() {
        #expect(Kernel.System.allocationGranularity > 0)
    }

    @Test("allocationGranularity is power of 2")
    func allocationGranularityPowerOfTwo() {
        let size = Int(Kernel.System.allocationGranularity)
        // A power of 2 has exactly one bit set
        #expect(size & (size - 1) == 0)
    }

    #if !os(Windows)
        @Test("allocationGranularity equals pageSize on POSIX")
        func allocationGranularityEqualsPageSize() {
            // Compare underlying values since these are different Tagged types
            #expect(Int(Kernel.System.allocationGranularity) == Int(Kernel.System.pageSize))
        }
    #endif
}

// MARK: - Consistency Tests

extension Kernel.System.Test.Unit {
    @Test("pageSize is consistent across calls")
    func pageSizeConsistent() {
        let size1 = Kernel.System.pageSize
        let size2 = Kernel.System.pageSize
        let size3 = Kernel.System.pageSize

        #expect(size1 == size2)
        #expect(size2 == size3)
    }

    @Test("allocationGranularity is consistent across calls")
    func allocationGranularityConsistent() {
        let size1 = Kernel.System.allocationGranularity
        let size2 = Kernel.System.allocationGranularity

        #expect(size1 == size2)
    }
}
