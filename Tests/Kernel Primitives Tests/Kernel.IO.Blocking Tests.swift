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

extension Kernel.IO.Blocking {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.IO.Blocking.Test.Unit {
    @Test("Blocking namespace exists")
    func namespaceExists() {
        // Kernel.IO.Blocking is a public enum namespace
        _ = Kernel.IO.Blocking.self
    }

    @Test("Blocking is an enum")
    func isEnum() {
        let _: Kernel.IO.Blocking.Type = Kernel.IO.Blocking.self
    }

    @Test("Blocking is Sendable")
    func isSendable() {
        let _: any Sendable.Type = Kernel.IO.Blocking.self
    }
}

// MARK: - Nested Types

extension Kernel.IO.Blocking.Test.Unit {
    @Test("Blocking.Error type exists")
    func errorTypeExists() {
        let _: Kernel.IO.Blocking.Error.Type = Kernel.IO.Blocking.Error.self
    }
}
