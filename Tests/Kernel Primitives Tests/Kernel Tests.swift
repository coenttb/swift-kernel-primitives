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

extension Kernel {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Test.Unit {
    @Test("Kernel namespace exists")
    func namespaceExists() {
        // Kernel is a public enum namespace
        // If it compiles, it exists
        _ = Kernel.self
    }

    @Test("Kernel is an enum")
    func isEnum() {
        // Kernel is declared as: public enum Kernel {}
        // Enums with no cases cannot be instantiated
        // This test verifies the type is accessible
        let _: Kernel.Type = Kernel.self
    }
}

// MARK: - Nested Namespaces

extension Kernel.Test.Unit {
    @Test("Kernel.File namespace exists")
    func fileNamespaceExists() {
        _ = Kernel.File.self
    }

    @Test("Kernel.Memory namespace exists")
    func memoryNamespaceExists() {
        _ = Kernel.Memory.self
    }

    @Test("Kernel.IO namespace exists")
    func ioNamespaceExists() {
        _ = Kernel.IO.self
    }

    @Test("Kernel.Event namespace exists")
    func eventNamespaceExists() {
        _ = Kernel.Event.self
    }

    @Test("Kernel.Thread namespace exists")
    func threadNamespaceExists() {
        _ = Kernel.Thread.self
    }

    @Test("Kernel.Lock namespace exists")
    func lockNamespaceExists() {
        _ = Kernel.Lock.self
    }
}
