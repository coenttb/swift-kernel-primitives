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

extension Kernel.Error.Unmapped {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Error.Unmapped.Test.Unit {
    @Test("Unmapped namespace exists")
    func namespaceExists() {
        _ = Kernel.Error.Unmapped.self
    }

    @Test("Unmapped is an enum")
    func isEnum() {
        let _: Kernel.Error.Unmapped.Type = Kernel.Error.Unmapped.self
    }
}

// MARK: - Nested Types

extension Kernel.Error.Unmapped.Test.Unit {
    @Test("Unmapped.Error type exists")
    func errorTypeExists() {
        let _: Kernel.Error.Unmapped.Error.Type = Kernel.Error.Unmapped.Error.self
    }
}
