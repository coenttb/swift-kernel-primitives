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

extension Kernel.Memory {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Memory.Test.Unit {
    @Test("Memory namespace exists")
    func namespaceExists() {
        // Kernel.Memory is a public enum namespace
        _ = Kernel.Memory.self
    }

    @Test("Memory is an enum")
    func isEnum() {
        let _: Kernel.Memory.Type = Kernel.Memory.self
    }

    @Test("Memory is Sendable")
    func isSendable() {
        let _: any Sendable.Type = Kernel.Memory.self
    }
}

// MARK: - Nested Types

extension Kernel.Memory.Test.Unit {
    @Test("Memory.Error type exists")
    func errorTypeExists() {
        let _: Kernel.Memory.Error.Type = Kernel.Memory.Error.self
    }

    @Test("Memory.Map namespace exists")
    func mapNamespaceExists() {
        let _: Kernel.Memory.Map.Type = Kernel.Memory.Map.self
    }

    @Test("Memory.Address typealias exists")
    func addressTypealiasExists() {
        let _: Kernel.Memory.Address.Type = Kernel.Memory.Address.self
    }
}
