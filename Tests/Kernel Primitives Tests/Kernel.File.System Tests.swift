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

extension Kernel.File.System {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.System.Test.Unit {
    @Test("System namespace exists")
    func namespaceExists() {
        _ = Kernel.File.System.self
    }

    @Test("System is an enum")
    func isEnum() {
        let _: Kernel.File.System.Type = Kernel.File.System.self
    }
}

// MARK: - Nested Types

extension Kernel.File.System.Test.Unit {
    @Test("System.Kind type exists")
    func kindTypeExists() {
        let _: Kernel.File.System.Kind.Type = Kernel.File.System.Kind.self
    }

    @Test("System.Stats type exists")
    func statsTypeExists() {
        let _: Kernel.File.System.Stats.Type = Kernel.File.System.Stats.self
    }

    @Test("System.Block type exists")
    func blockTypeExists() {
        let _: Kernel.File.System.Block.Type = Kernel.File.System.Block.self
    }
}
