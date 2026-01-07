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

extension Kernel.Copy.Error {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Copy.Error.Test.Unit {
    @Test("invalidDescriptor case exists")
    func invalidDescriptorCase() {
        let error = Kernel.Copy.Error.invalidDescriptor
        if case .invalidDescriptor = error {
            // Expected
        } else {
            Issue.record("Expected .invalidDescriptor case")
        }
    }

    @Test("crossDevice case exists")
    func crossDeviceCase() {
        let error = Kernel.Copy.Error.crossDevice
        if case .crossDevice = error {
            // Expected
        } else {
            Issue.record("Expected .crossDevice case")
        }
    }

    @Test("unsupported case exists")
    func unsupportedCase() {
        let error = Kernel.Copy.Error.unsupported
        if case .unsupported = error {
            // Expected
        } else {
            Issue.record("Expected .unsupported case")
        }
    }

    @Test("noSpace case exists")
    func noSpaceCase() {
        let error = Kernel.Copy.Error.noSpace
        if case .noSpace = error {
            // Expected
        } else {
            Issue.record("Expected .noSpace case")
        }
    }

    @Test("io case exists")
    func ioCase() {
        let error = Kernel.Copy.Error.io
        if case .io = error {
            // Expected
        } else {
            Issue.record("Expected .io case")
        }
    }

    @Test("permissionDenied case exists")
    func permissionDeniedCase() {
        let error = Kernel.Copy.Error.permissionDenied
        if case .permissionDenied = error {
            // Expected
        } else {
            Issue.record("Expected .permissionDenied case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.Copy.Error.Test.Unit {
    @Test("invalidDescriptor description")
    func invalidDescriptorDescription() {
        #expect(Kernel.Copy.Error.invalidDescriptor.description == "invalid file descriptor")
    }

    @Test("crossDevice description")
    func crossDeviceDescription() {
        #expect(Kernel.Copy.Error.crossDevice.description == "cross-device copy not supported")
    }

    @Test("unsupported description")
    func unsupportedDescription() {
        #expect(Kernel.Copy.Error.unsupported.description == "operation not supported")
    }

    @Test("noSpace description")
    func noSpaceDescription() {
        #expect(Kernel.Copy.Error.noSpace.description == "no space left on device")
    }

    @Test("io description")
    func ioDescription() {
        #expect(Kernel.Copy.Error.io.description == "I/O error")
    }

    @Test("permissionDenied description")
    func permissionDeniedDescription() {
        #expect(Kernel.Copy.Error.permissionDenied.description == "permission denied")
    }
}

// MARK: - Conformance Tests

extension Kernel.Copy.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Kernel.Copy.Error.invalidDescriptor
        #expect(error is Kernel.Copy.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let error: any Sendable = Kernel.Copy.Error.invalidDescriptor
        #expect(error is Kernel.Copy.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Kernel.Copy.Error.invalidDescriptor
        let b = Kernel.Copy.Error.invalidDescriptor
        let c = Kernel.Copy.Error.crossDevice
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Error is Hashable")
    func isHashable() {
        var set = Set<Kernel.Copy.Error>()
        set.insert(.invalidDescriptor)
        set.insert(.crossDevice)
        set.insert(.invalidDescriptor)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Copy.Error.Test.EdgeCase {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let cases: [Kernel.Copy.Error] = [
            .invalidDescriptor,
            .crossDevice,
            .unsupported,
            .noSpace,
            .io,
            .permissionDenied,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}

// MARK: - POSIX Error Mapping Tests

#if !os(Windows)
    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    extension Kernel.Copy.Error.Test.Unit {
        @Test("EBADF maps to invalidDescriptor")
        func ebadfMapping() {
            let error = Kernel.Copy.Error(posix: EBADF)
            #expect(error == .invalidDescriptor)
        }

        @Test("EXDEV maps to crossDevice")
        func exdevMapping() {
            let error = Kernel.Copy.Error(posix: EXDEV)
            #expect(error == .crossDevice)
        }

        @Test("EINVAL maps to unsupported")
        func einvalMapping() {
            let error = Kernel.Copy.Error(posix: EINVAL)
            #expect(error == .unsupported)
        }

        @Test("ENOTSUP maps to unsupported")
        func enotsupMapping() {
            let error = Kernel.Copy.Error(posix: ENOTSUP)
            #expect(error == .unsupported)
        }

        @Test("EOPNOTSUPP maps to unsupported")
        func eopnotsuppMapping() {
            let error = Kernel.Copy.Error(posix: EOPNOTSUPP)
            #expect(error == .unsupported)
        }

        @Test("ENOSPC maps to noSpace")
        func enospcMapping() {
            let error = Kernel.Copy.Error(posix: ENOSPC)
            #expect(error == .noSpace)
        }

        @Test("EIO maps to io")
        func eioMapping() {
            let error = Kernel.Copy.Error(posix: EIO)
            #expect(error == .io)
        }

        @Test("EACCES maps to permissionDenied")
        func eaccesMapping() {
            let error = Kernel.Copy.Error(posix: EACCES)
            #expect(error == .permissionDenied)
        }

        @Test("EPERM maps to permissionDenied")
        func epermMapping() {
            let error = Kernel.Copy.Error(posix: EPERM)
            #expect(error == .permissionDenied)
        }

        @Test("unknown error maps to unsupported")
        func unknownMapping() {
            // Use an unlikely error code
            let error = Kernel.Copy.Error(posix: 999)
            #expect(error == .unsupported)
        }
    }
#endif
