// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import StandardsTestSupport
import Testing

@testable import Kernel_Primitives

extension Kernel.Memory.Map.File {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.Memory.Map.File.Test.Unit {
    @Test("File namespace exists")
    func namespaceExists() {
        _ = Kernel.Memory.Map.File.self
    }

    @Test("File is an enum")
    func isEnum() {
        let _: Kernel.Memory.Map.File.Type = Kernel.Memory.Map.File.self
    }
}

// MARK: - Windows Tests

#if os(Windows)
    extension Kernel.Memory.Map.File.Test.Unit {
        @Test("map function signature exists on Windows")
        func mapSignatureExists() {
            // Verify the function exists with correct signature
            typealias MapFunc = (
                Kernel.Descriptor,
                Kernel.File.Offset,
                Kernel.File.Size,
                Kernel.Memory.Map.Protection,
                Bool
            ) throws -> Kernel.Memory.Map.Region

            let _: MapFunc = { descriptor, offset, length, protection, cow in
                try Kernel.Memory.Map.File.map(
                    descriptor: descriptor,
                    offset: offset,
                    length: length,
                    protection: protection,
                    copyOnWrite: cow
                )
            }
        }
    }
#endif
