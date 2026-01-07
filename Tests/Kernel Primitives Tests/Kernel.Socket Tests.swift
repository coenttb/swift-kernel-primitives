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

extension Kernel.Socket {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Socket.Test.Unit {
    @Test("Socket namespace exists")
    func namespaceExists() {
        _ = Kernel.Socket.self
    }

    @Test("Socket is an enum")
    func isEnum() {
        let _: Kernel.Socket.Type = Kernel.Socket.self
    }
}

// MARK: - Nested Types

extension Kernel.Socket.Test.Unit {
    @Test("Socket.Descriptor type exists")
    func descriptorTypeExists() {
        let _: Kernel.Socket.Descriptor.Type = Kernel.Socket.Descriptor.self
    }

    @Test("Socket.Error type exists")
    func errorTypeExists() {
        let _: Kernel.Socket.Error.Type = Kernel.Socket.Error.self
    }

    @Test("Socket.Backlog type exists")
    func backlogTypeExists() {
        let _: Kernel.Socket.Backlog.Type = Kernel.Socket.Backlog.self
    }

    @Test("Socket.Shutdown type exists")
    func shutdownTypeExists() {
        let _: Kernel.Socket.Shutdown.Type = Kernel.Socket.Shutdown.self
    }

    #if !os(Windows)
        @Test("Socket.Flags type exists")
        func flagsTypeExists() {
            let _: Kernel.Socket.Flags.Type = Kernel.Socket.Flags.self
        }
    #endif
}
