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

extension Kernel.Environment {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Environment.Test.Unit {
    @Test("Environment namespace exists")
    func namespaceExists() {
        _ = Kernel.Environment.self
    }

    @Test("Environment is an enum")
    func isEnum() {
        let _: Kernel.Environment.Type = Kernel.Environment.self
    }
}

// MARK: - Get Tests

extension Kernel.Environment.Test.Unit {
    @Test("get returns nil for unset variable")
    func getUnsetVariable() {
        let result = Kernel.Environment.get("__KERNEL_TEST_UNSET_VAR_12345__")
        #expect(result == nil)
    }

    @Test("get returns value for PATH")
    func getPathVariable() {
        // PATH should always be set on all platforms
        let result = Kernel.Environment.get("PATH")
        #expect(result != nil)
    }
}

// MARK: - isSet Tests

extension Kernel.Environment.Test.Unit {
    @Test("isSet returns false for unset variable")
    func isSetUnsetVariable() {
        let result = Kernel.Environment.isSet("__KERNEL_TEST_UNSET_VAR_12345__")
        #expect(result == false)
    }

    @Test("isSet returns true for PATH")
    func isSetPathVariable() {
        let result = Kernel.Environment.isSet("PATH")
        #expect(result == true)
    }

    @Test("isSet with value checks exact match")
    func isSetWithValue() {
        // Test with a non-existent value
        let result = Kernel.Environment.isSet("PATH", to: "__IMPOSSIBLE_VALUE__")
        #expect(result == false)
    }
}
