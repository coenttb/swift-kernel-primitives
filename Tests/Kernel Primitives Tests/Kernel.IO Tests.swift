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

extension Kernel.IO {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.IO.Test.Unit {
    @Test("IO namespace exists")
    func namespaceExists() {
        // Kernel.IO is a public enum namespace
        _ = Kernel.IO.self
    }

    @Test("IO is an enum")
    func isEnum() {
        let _: Kernel.IO.Type = Kernel.IO.self
    }

    @Test("IO is Sendable")
    func isSendable() {
        // The enum type itself conforms to Sendable
        let _: any Sendable.Type = Kernel.IO.self
    }
}

// MARK: - Nested Types

extension Kernel.IO.Test.Unit {
    @Test("IO.Error type exists")
    func errorTypeExists() {
        let _: Kernel.IO.Error.Type = Kernel.IO.Error.self
    }

    @Test("IO.Blocking namespace exists")
    func blockingNamespaceExists() {
        let _: Kernel.IO.Blocking.Type = Kernel.IO.Blocking.self
    }

    @Test("IO.Read namespace exists")
    func readNamespaceExists() {
        let _: Kernel.IO.Read.Type = Kernel.IO.Read.self
    }

    @Test("IO.Write namespace exists")
    func writeNamespaceExists() {
        let _: Kernel.IO.Write.Type = Kernel.IO.Write.self
    }
}
