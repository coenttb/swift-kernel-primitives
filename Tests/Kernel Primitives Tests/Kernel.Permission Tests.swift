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

extension Kernel.Permission {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Permission.Test.Unit {
    @Test("Permission namespace exists")
    func namespaceExists() {
        _ = Kernel.Permission.self
    }

    @Test("Permission is an enum")
    func isEnum() {
        let _: Kernel.Permission.Type = Kernel.Permission.self
    }
}

// MARK: - Nested Types

extension Kernel.Permission.Test.Unit {
    @Test("Permission.Error type exists")
    func errorTypeExists() {
        let _: Kernel.Permission.Error.Type = Kernel.Permission.Error.self
    }
}
