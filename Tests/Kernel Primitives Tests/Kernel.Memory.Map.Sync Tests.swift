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

extension Kernel.Memory.Map.Sync {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Memory.Map.Sync.Test.Unit {
    @Test("Sync namespace exists")
    func namespaceExists() {
        _ = Kernel.Memory.Map.Sync.self
    }

    @Test("Sync is an enum")
    func isEnum() {
        let _: Kernel.Memory.Map.Sync.Type = Kernel.Memory.Map.Sync.self
    }

    @Test("Sync is Sendable")
    func isSendable() {
        let _: any Sendable.Type = Kernel.Memory.Map.Sync.self
    }

    @Test("Sync is Equatable")
    func isEquatable() {
        // The enum itself has no cases, but it's Equatable by definition
        let _: any Equatable.Type = Kernel.Memory.Map.Sync.self
    }

    @Test("Sync is Hashable")
    func isHashable() {
        let _: any Hashable.Type = Kernel.Memory.Map.Sync.self
    }
}

// MARK: - Nested Types

extension Kernel.Memory.Map.Sync.Test.Unit {
    @Test("Sync.Flags type exists")
    func flagsTypeExists() {
        let _: Kernel.Memory.Map.Sync.Flags.Type = Kernel.Memory.Map.Sync.Flags.self
    }
}
