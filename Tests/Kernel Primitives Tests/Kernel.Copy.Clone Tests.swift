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

#if os(Linux) || canImport(Darwin)

    extension Kernel.Copy.Clone {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.Copy.Clone.Test.Unit {
        @Test("Clone namespace exists")
        func namespaceExists() {
            // Kernel.Copy.Clone is a public enum namespace
            _ = Kernel.Copy.Clone.self
        }

        @Test("Clone is an enum")
        func isEnum() {
            let _: Kernel.Copy.Clone.Type = Kernel.Copy.Clone.self
        }
    }

    // MARK: - Platform-Specific API Tests

    #if os(Linux)
        extension Kernel.Copy.Clone.Test.Unit {
            @Test("perform function signature exists on Linux")
            func performSignatureExists() {
                // Verify the function exists with correct signature
                // (cannot actually call it without valid descriptors)
                let _: (Kernel.Descriptor, Kernel.Descriptor) throws -> Void = {
                    (source: Kernel.Descriptor, dest: Kernel.Descriptor) throws(Kernel.Copy.Error) in
                    try Kernel.Copy.Clone.perform(from: source, to: dest)
                }
            }
        }
    #endif

    #if canImport(Darwin)
        extension Kernel.Copy.Clone.Test.Unit {
            @Test("file function signature exists on Darwin")
            func fileSignatureExists() {
                // Verify the function exists with correct signature
                let _: (String, String) throws -> Void = {
                    (source: String, dest: String) throws(Kernel.Copy.Error) in
                    try Kernel.Copy.Clone.file(from: source, to: dest)
                }
            }
        }
    #endif

#endif
