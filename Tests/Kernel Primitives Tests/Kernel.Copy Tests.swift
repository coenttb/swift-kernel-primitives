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

extension Kernel.Copy {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Copy.Test.Unit {
    @Test("Copy namespace exists")
    func namespaceExists() {
        // Kernel.Copy is a public enum namespace
        _ = Kernel.Copy.self
    }

    @Test("Copy is an enum")
    func isEnum() {
        let _: Kernel.Copy.Type = Kernel.Copy.self
    }

    @Test("Copy is Sendable")
    func isSendable() {
        let _: any Sendable.Type = Kernel.Copy.self
    }
}

// MARK: - Nested Types

extension Kernel.Copy.Test.Unit {
    @Test("Copy.Error type exists")
    func errorTypeExists() {
        let _: Kernel.Copy.Error.Type = Kernel.Copy.Error.self
    }

    #if os(Linux) || canImport(Darwin)
        @Test("Copy.Clone namespace exists")
        func cloneNamespaceExists() {
            let _: Kernel.Copy.Clone.Type = Kernel.Copy.Clone.self
        }
    #endif

    #if os(Linux)
        @Test("Copy.Range namespace exists on Linux")
        func rangeNamespaceExists() {
            let _: Kernel.Copy.Range.Type = Kernel.Copy.Range.self
        }
    #endif
}
