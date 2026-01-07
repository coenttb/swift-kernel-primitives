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

extension Kernel.File.Direct {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Test.Unit {
    @Test("Direct namespace exists")
    func namespaceExists() {
        _ = Kernel.File.Direct.self
    }

    @Test("Direct is an enum")
    func isEnum() {
        let _: Kernel.File.Direct.Type = Kernel.File.Direct.self
    }
}

// MARK: - Nested Types

extension Kernel.File.Direct.Test.Unit {
    @Test("Direct.Capability type exists")
    func capabilityTypeExists() {
        let _: Kernel.File.Direct.Capability.Type = Kernel.File.Direct.Capability.self
    }

    @Test("Direct.Mode type exists")
    func modeTypeExists() {
        let _: Kernel.File.Direct.Mode.Type = Kernel.File.Direct.Mode.self
    }

    @Test("Direct.Requirements type exists")
    func requirementsTypeExists() {
        let _: Kernel.File.Direct.Requirements.Type = Kernel.File.Direct.Requirements.self
    }

    @Test("Direct.Error type exists")
    func errorTypeExists() {
        let _: Kernel.File.Direct.Error.Type = Kernel.File.Direct.Error.self
    }
}

// MARK: - Static Methods

extension Kernel.File.Direct.Test.Unit {
    #if canImport(Darwin) || canImport(Glibc) || canImport(Musl)
    @Test("requirements(for:) returns Requirements")
    func requirementsForPath() {
        "/tmp".withCString { cString in
            let path = Kernel.Path(unsafeCString: cString)
            let requirements = Kernel.File.Direct.requirements(for: path)
            switch requirements {
            case .known:
                // Windows may return known
                break
            case .unknown:
                // macOS/Linux return unknown
                break
            }
        }
    }
    #endif
}
