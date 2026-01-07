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

extension Kernel.Event {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Event.Test.Unit {
    @Test("Event namespace exists")
    func namespaceExists() {
        // Kernel.Event is a public enum namespace
        _ = Kernel.Event.self
    }

    @Test("Event is an enum")
    func isEnum() {
        let _: Kernel.Event.Type = Kernel.Event.self
    }
}

// MARK: - Nested Types

extension Kernel.Event.Test.Unit {
    @Test("Event.ID typealias exists")
    func idTypealiasExists() {
        // Event.ID is a typealias to Tagged<Kernel.Event, UInt>
        let _: Kernel.Event.ID.Type = Kernel.Event.ID.self
    }
}
