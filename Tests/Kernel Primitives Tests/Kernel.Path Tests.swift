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

extension Kernel.Path {
    #TestSuites
}

// MARK: - Unit Tests
// Note: These tests use POSIX-style C strings (CChar). On Windows,
// Kernel.Path uses wide strings (UInt16), so these tests are skipped.

#if !os(Windows)
    extension Kernel.Path.Test.Unit {
        @Test("Path stores C string pointer")
        func storesCString() {
            "/tmp/test".withCString { cString in
                let path = Kernel.Path(unsafeCString: cString)
                #expect(path.unsafeCString == cString)
            }
        }

        @Test("Path is non-Copyable")
        func isNonCopyable() {
            // This test verifies compilation behavior
            // Kernel.Path: ~Copyable means it cannot be copied
            "/tmp/test".withCString { cString in
                let path = Kernel.Path(unsafeCString: cString)
                // Cannot do: let copy = path (would not compile)
                _ = path.unsafeCString
            }
        }
    }

    // MARK: - Edge Cases

    extension Kernel.Path.Test.EdgeCase {
        @Test("Path with empty string")
        func emptyString() {
            "".withCString { cString in
                let path = Kernel.Path(unsafeCString: cString)
                #expect(path.unsafeCString == cString)
            }
        }

        @Test("Path with special characters")
        func specialCharacters() {
            "/tmp/test file with spaces.txt".withCString { cString in
                let path = Kernel.Path(unsafeCString: cString)
                #expect(path.unsafeCString == cString)
            }
        }

        @Test("Path with unicode characters")
        func unicodeCharacters() {
            "/tmp/日本語/文件.txt".withCString { cString in
                let path = Kernel.Path(unsafeCString: cString)
                #expect(path.unsafeCString == cString)
            }
        }

        @Test("Path with long name")
        func longPathName() {
            let longComponent = String(repeating: "a", count: 200)
            "/tmp/\(longComponent)".withCString { cString in
                let path = Kernel.Path(unsafeCString: cString)
                #expect(path.unsafeCString == cString)
            }
        }

        @Test("Path with relative components")
        func relativeComponents() {
            "../relative/path/./here".withCString { cString in
                let path = Kernel.Path(unsafeCString: cString)
                #expect(path.unsafeCString == cString)
            }
        }
    }

    // MARK: - Char Type Tests

    extension Kernel.Path.Test.Unit {
        @Test("Char typealias exists")
        func charTypealiasExists() {
            // Kernel.Path.Char is CChar on POSIX, UInt16 on Windows
            let _: Kernel.Path.Char.Type = CChar.self
        }
    }
#endif
