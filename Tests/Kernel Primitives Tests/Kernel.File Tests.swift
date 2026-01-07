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

extension Kernel.File {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Test.Unit {
    @Test("File namespace exists")
    func namespaceExists() {
        // Kernel.File is an enum namespace, verify it compiles
        _ = Kernel.File.self
    }
}
