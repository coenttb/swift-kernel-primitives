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
#if !os(Windows)
// @testable import Kernel_POSIX  // Not available in primitives package
#endif

// Kernel.Error.Mapping.swift contains extension initializers for error mapping.
// These tests verify the error mapping functionality using Kernel.Error.Code.

#if !os(Windows)

    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    // MARK: - Path.Resolution.Error Mapping Tests

    @Suite("Path.Resolution.Error Mapping")
    struct PathResolutionErrorMappingTests {
        @Test("notFound from ENOENT")
        func notFoundMapping() {
            let error = Kernel.Path.Resolution.Error(code: .posix(ENOENT))
            #expect(error == .notFound)
        }

        @Test("exists from EEXIST")
        func existsMapping() {
            let error = Kernel.Path.Resolution.Error(code: .posix(EEXIST))
            #expect(error == .exists)
        }

        @Test("isDirectory from EISDIR")
        func isDirectoryMapping() {
            let error = Kernel.Path.Resolution.Error(code: .posix(EISDIR))
            #expect(error == .isDirectory)
        }

        @Test("notDirectory from ENOTDIR")
        func notDirectoryMapping() {
            let error = Kernel.Path.Resolution.Error(code: .posix(ENOTDIR))
            #expect(error == .notDirectory)
        }

        @Test("returns nil for unmapped errno")
        func unmappedReturnsNil() {
            let error = Kernel.Path.Resolution.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    // MARK: - Permission.Error Mapping Tests

    @Suite("Permission.Error Mapping")
    struct PermissionErrorMappingTests {
        @Test("denied from EACCES")
        func deniedMapping() {
            let error = Kernel.Permission.Error(code: .posix(EACCES))
            #expect(error == .denied)
        }

        @Test("notPermitted from EPERM")
        func notPermittedMapping() {
            let error = Kernel.Permission.Error(code: .posix(EPERM))
            #expect(error == .notPermitted)
        }

        @Test("readOnlyFilesystem from EROFS")
        func readOnlyFilesystemMapping() {
            let error = Kernel.Permission.Error(code: .posix(EROFS))
            #expect(error == .readOnlyFilesystem)
        }

        @Test("returns nil for unmapped errno")
        func unmappedReturnsNil() {
            let error = Kernel.Permission.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    // MARK: - Descriptor.Validity.Error Mapping Tests

    @Suite("Descriptor.Validity.Error Mapping")
    struct DescriptorValidityErrorMappingTests {
        @Test("invalid from EBADF")
        func invalidMapping() {
            let error = Kernel.Descriptor.Validity.Error(code: .posix(EBADF))
            #expect(error == .invalid)
        }

        @Test("limit process from EMFILE")
        func processLimitMapping() {
            let error = Kernel.Descriptor.Validity.Error(code: .posix(EMFILE))
            #expect(error == .limit(.process))
        }

        @Test("limit system from ENFILE")
        func systemLimitMapping() {
            let error = Kernel.Descriptor.Validity.Error(code: .posix(ENFILE))
            #expect(error == .limit(.system))
        }

        @Test("returns nil for unmapped errno")
        func unmappedReturnsNil() {
            let error = Kernel.Descriptor.Validity.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    // MARK: - IO.Blocking.Error Mapping Tests

    @Suite("IO.Blocking.Error Mapping")
    struct IOBlockingErrorMappingTests {
        @Test("wouldBlock from EAGAIN")
        func wouldBlockMapping() {
            let error = Kernel.IO.Blocking.Error(code: .posix(EAGAIN))
            #expect(error == .wouldBlock)
        }

        @Test("returns nil for unmapped errno")
        func unmappedReturnsNil() {
            let error = Kernel.IO.Blocking.Error(code: .posix(EACCES))
            #expect(error == nil)
        }
    }

    // MARK: - Storage.Error Mapping Tests

    @Suite("Storage.Error Mapping")
    struct StorageErrorMappingTests {
        @Test("exhausted from ENOSPC")
        func exhaustedMapping() {
            let error = Kernel.Storage.Error(code: .posix(ENOSPC))
            #expect(error == .exhausted)
        }

        @Test("quota from EDQUOT")
        func quotaMapping() {
            let error = Kernel.Storage.Error(code: .posix(EDQUOT))
            #expect(error == .quota)
        }

        @Test("returns nil for unmapped errno")
        func unmappedReturnsNil() {
            let error = Kernel.Storage.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    // MARK: - Memory.Error Mapping Tests

    @Suite("Memory.Error Mapping")
    struct MemoryErrorMappingTests {
        @Test("fault from EFAULT")
        func faultMapping() {
            let error = Kernel.Memory.Error(code: .posix(EFAULT))
            #expect(error == .fault)
        }

        @Test("exhausted from ENOMEM")
        func exhaustedMapping() {
            let error = Kernel.Memory.Error(code: .posix(ENOMEM))
            #expect(error == .exhausted)
        }

        @Test("returns nil for unmapped errno")
        func unmappedReturnsNil() {
            let error = Kernel.Memory.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    // MARK: - IO.Error Mapping Tests

    @Suite("IO.Error Mapping")
    struct IOErrorMappingTests {
        @Test("hardware from EIO")
        func hardwareMapping() {
            let error = Kernel.IO.Error(code: .posix(EIO))
            #expect(error == .hardware)
        }

        @Test("broken from EPIPE")
        func brokenMapping() {
            let error = Kernel.IO.Error(code: .posix(EPIPE))
            #expect(error == .broken)
        }

        @Test("reset from ECONNRESET")
        func resetMapping() {
            let error = Kernel.IO.Error(code: .posix(ECONNRESET))
            #expect(error == .reset)
        }

        @Test("returns nil for unmapped errno")
        func unmappedReturnsNil() {
            let error = Kernel.IO.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    // MARK: - Kernel.Error Tests

    @Suite("Kernel.Error")
    struct KernelErrorTests {
        @Test("creates error from errno code")
        func fromErrno() {
            let error = Kernel.Error(code: .posix(EINTR))
            if case .posix(let value) = error.code {
                #expect(value == EINTR)
            } else {
                Issue.record("Expected .posix code")
            }
        }

        @Test("error is Sendable")
        func isSendable() {
            let error: any Sendable = Kernel.Error(code: .posix(EINTR))
            #expect(error is Kernel.Error)
        }

        @Test("error is Equatable")
        func isEquatable() {
            let a = Kernel.Error(code: .posix(EINTR))
            let b = Kernel.Error(code: .posix(EINTR))
            let c = Kernel.Error(code: .posix(ENOENT))
            #expect(a == b)
            #expect(a != c)
        }

        @Test("error is Hashable")
        func isHashable() {
            var set = Set<Kernel.Error>()
            set.insert(Kernel.Error(code: .posix(1)))
            set.insert(Kernel.Error(code: .posix(2)))
            set.insert(Kernel.Error(code: .posix(1)))  // duplicate
            #expect(set.count == 2)
        }
    }

#endif
