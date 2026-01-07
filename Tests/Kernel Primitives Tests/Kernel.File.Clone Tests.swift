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

extension Kernel.File.Clone {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Clone.Test.Unit {
    @Test("Clone namespace exists")
    func namespaceExists() {
        _ = Kernel.File.Clone.self
    }

    @Test("Clone is an enum")
    func isEnum() {
        let _: Kernel.File.Clone.Type = Kernel.File.Clone.self
    }
}

// MARK: - Nested Types

extension Kernel.File.Clone.Test.Unit {
    @Test("Clone.Capability type exists")
    func capabilityTypeExists() {
        let _: Kernel.File.Clone.Capability.Type = Kernel.File.Clone.Capability.self
    }

    @Test("Clone.Behavior type exists")
    func behaviorTypeExists() {
        let _: Kernel.File.Clone.Behavior.Type = Kernel.File.Clone.Behavior.self
    }

    @Test("Clone.Error type exists")
    func errorTypeExists() {
        let _: Kernel.File.Clone.Error.Type = Kernel.File.Clone.Error.self
    }

    @Test("Clone.Result type exists")
    func resultTypeExists() {
        let _: Kernel.File.Clone.Result.Type = Kernel.File.Clone.Result.self
    }
}
