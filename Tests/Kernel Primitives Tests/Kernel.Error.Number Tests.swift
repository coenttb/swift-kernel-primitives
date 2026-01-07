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

extension Kernel.Error.Number {
    #TestSuites
}

// MARK: - Error Number Tests

#if !os(Windows)

    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    extension Kernel.Error.Number.Test.Unit {
        @Test("noEntry equals ENOENT")
        func noEntryEqualsENOENT() {
            #expect(Kernel.Error.Number.noEntry == Kernel.Error.Number(ENOENT))
        }

        @Test("accessDenied equals EACCES")
        func accessDeniedEqualsEACCES() {
            #expect(Kernel.Error.Number.accessDenied == Kernel.Error.Number(EACCES))
        }

        @Test("notPermitted equals EPERM")
        func notPermittedEqualsEPERM() {
            #expect(Kernel.Error.Number.notPermitted == Kernel.Error.Number(EPERM))
        }

        @Test("exists equals EEXIST")
        func existsEqualsEEXIST() {
            #expect(Kernel.Error.Number.exists == Kernel.Error.Number(EEXIST))
        }

        @Test("isDirectory equals EISDIR")
        func isDirectoryEqualsEISDIR() {
            #expect(Kernel.Error.Number.isDirectory == Kernel.Error.Number(EISDIR))
        }

        @Test("processLimit equals EMFILE")
        func processLimitEqualsEMFILE() {
            #expect(Kernel.Error.Number.processLimit == Kernel.Error.Number(EMFILE))
        }

        @Test("systemLimit equals ENFILE")
        func systemLimitEqualsENFILE() {
            #expect(Kernel.Error.Number.systemLimit == Kernel.Error.Number(ENFILE))
        }

        @Test("invalid equals EINVAL")
        func invalidEqualsEINVAL() {
            #expect(Kernel.Error.Number.invalid == Kernel.Error.Number(EINVAL))
        }

        @Test("interrupted equals EINTR")
        func interruptedEqualsEINTR() {
            #expect(Kernel.Error.Number.interrupted == Kernel.Error.Number(EINTR))
        }

        @Test("wouldBlock equals EAGAIN")
        func wouldBlockEqualsEAGAIN() {
            #expect(Kernel.Error.Number.wouldBlock == Kernel.Error.Number(EAGAIN))
        }

        @Test("noDevice equals ENODEV")
        func noDeviceEqualsENODEV() {
            #expect(Kernel.Error.Number.noDevice == Kernel.Error.Number(ENODEV))
        }

        @Test("notDirectory equals ENOTDIR")
        func notDirectoryEqualsENOTDIR() {
            #expect(Kernel.Error.Number.notDirectory == Kernel.Error.Number(ENOTDIR))
        }

        @Test("readOnlyFilesystem equals EROFS")
        func readOnlyFilesystemEqualsEROFS() {
            #expect(Kernel.Error.Number.readOnlyFilesystem == Kernel.Error.Number(EROFS))
        }

        @Test("noSpace equals ENOSPC")
        func noSpaceEqualsENOSPC() {
            #expect(Kernel.Error.Number.noSpace == Kernel.Error.Number(ENOSPC))
        }

        @Test("badDescriptor equals EBADF")
        func badDescriptorEqualsEBADF() {
            #expect(Kernel.Error.Number.badDescriptor == Kernel.Error.Number(EBADF))
        }
    }

    extension Kernel.Error.Number.Test.Unit {
        @Test("all error number values are distinct")
        func allValuesDistinct() {
            let values: [Kernel.Error.Number] = [
                .noEntry,
                .accessDenied,
                .notPermitted,
                .exists,
                .isDirectory,
                .processLimit,
                .systemLimit,
                .invalid,
                .interrupted,
                .noDevice,
                .notDirectory,
                .readOnlyFilesystem,
                .noSpace,
                .badDescriptor,
            ]
            let uniqueValues = Set(values)
            #expect(uniqueValues.count == values.count, "All error number values should be distinct")
        }

        @Test("all error number values are positive")
        func allValuesPositive() {
            #expect(Kernel.Error.Number.noEntry > 0)
            #expect(Kernel.Error.Number.accessDenied > 0)
            #expect(Kernel.Error.Number.notPermitted > 0)
            #expect(Kernel.Error.Number.exists > 0)
            #expect(Kernel.Error.Number.invalid > 0)
            #expect(Kernel.Error.Number.interrupted > 0)
            #expect(Kernel.Error.Number.badDescriptor > 0)
        }
    }

#endif
