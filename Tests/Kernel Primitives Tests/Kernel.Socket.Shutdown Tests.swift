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

extension Kernel.Socket.Shutdown {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Socket.Shutdown.Test.Unit {
    @Test("Shutdown namespace exists")
    func namespaceExists() {
        _ = Kernel.Socket.Shutdown.self
    }

    @Test("Shutdown is an enum")
    func isEnum() {
        let _: Kernel.Socket.Shutdown.Type = Kernel.Socket.Shutdown.self
    }
}

// MARK: - Nested Types

extension Kernel.Socket.Shutdown.Test.Unit {
    @Test("Shutdown.How type exists")
    func howTypeExists() {
        let _: Kernel.Socket.Shutdown.How.Type = Kernel.Socket.Shutdown.How.self
    }

    @Test("Shutdown.Error type exists")
    func errorTypeExists() {
        let _: Kernel.Socket.Shutdown.Error.Type = Kernel.Socket.Shutdown.Error.self
    }
}
