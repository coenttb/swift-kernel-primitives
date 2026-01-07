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

extension Kernel.Storage {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Storage.Test.Unit {
    @Test("Storage namespace exists")
    func namespaceExists() {
        _ = Kernel.Storage.self
    }

    @Test("Storage is an enum")
    func isEnum() {
        let _: Kernel.Storage.Type = Kernel.Storage.self
    }
}

// MARK: - Nested Types

extension Kernel.Storage.Test.Unit {
    @Test("Storage.Error type exists")
    func errorTypeExists() {
        let _: Kernel.Storage.Error.Type = Kernel.Storage.Error.self
    }
}
