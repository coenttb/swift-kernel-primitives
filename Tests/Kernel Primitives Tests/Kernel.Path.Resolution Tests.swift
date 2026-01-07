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

extension Kernel.Path.Resolution {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Path.Resolution.Test.Unit {
    @Test("Resolution namespace exists")
    func namespaceExists() {
        // Kernel.Path.Resolution is a public enum namespace
        _ = Kernel.Path.Resolution.self
    }

    @Test("Resolution is an enum")
    func isEnum() {
        let _: Kernel.Path.Resolution.Type = Kernel.Path.Resolution.self
    }
}

// MARK: - Nested Types

extension Kernel.Path.Resolution.Test.Unit {
    @Test("Resolution.Error type exists")
    func errorTypeExists() {
        // Kernel.Path.Resolution.Error is the error type for path resolution
        let _: Kernel.Path.Resolution.Error.Type = Kernel.Path.Resolution.Error.self
    }
}
