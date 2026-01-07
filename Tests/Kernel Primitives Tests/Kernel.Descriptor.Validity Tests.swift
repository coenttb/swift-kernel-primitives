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

extension Kernel.Descriptor.Validity {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Descriptor.Validity.Test.Unit {
    @Test("Validity namespace exists")
    func namespaceExists() {
        _ = Kernel.Descriptor.Validity.self
    }

    @Test("Validity is an enum")
    func isEnum() {
        let _: Kernel.Descriptor.Validity.Type = Kernel.Descriptor.Validity.self
    }
}

// MARK: - Nested Types

extension Kernel.Descriptor.Validity.Test.Unit {
    @Test("Validity.Error type exists")
    func errorTypeExists() {
        let _: Kernel.Descriptor.Validity.Error.Type = Kernel.Descriptor.Validity.Error.self
    }
}
