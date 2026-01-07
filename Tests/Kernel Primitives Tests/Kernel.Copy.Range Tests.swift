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

#if os(Linux)
    import StandardsTestSupport
    import Testing

    @testable import Kernel_Primitives

    extension Kernel.Copy.Range {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.Copy.Range.Test.Unit {
        @Test("Range namespace exists")
        func namespaceExists() {
            // Kernel.Copy.Range is a public enum namespace (Linux only)
            _ = Kernel.Copy.Range.self
        }

        @Test("Range is an enum")
        func isEnum() {
            let _: Kernel.Copy.Range.Type = Kernel.Copy.Range.self
        }

        @Test("copy function signature exists")
        func copySignatureExists() {
            // Verify the function exists with correct signature
            // This is a compile-time check only
            typealias CopyFunc = (
                Kernel.Descriptor,
                inout Kernel.File.Offset,
                Kernel.Descriptor,
                inout Kernel.File.Offset,
                Kernel.File.Size
            ) throws -> Kernel.File.Size

            let _: CopyFunc = { source, sourceOffset, dest, destOffset, length in
                try Kernel.Copy.Range.copy(
                    from: source,
                    sourceOffset: &sourceOffset,
                    to: dest,
                    destOffset: &destOffset,
                    length: length
                )
            }
        }
    }
#endif
