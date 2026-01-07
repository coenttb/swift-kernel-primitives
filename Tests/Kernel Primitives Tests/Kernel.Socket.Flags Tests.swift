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

#if !os(Windows)

    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    import StandardsTestSupport
    import Testing

    @testable import Kernel_Primitives

    extension Kernel.Socket.Flags {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.Socket.Flags.Test.Unit {
        @Test("Flags type exists")
        func typeExists() {
            let _: Kernel.Socket.Flags.Type = Kernel.Socket.Flags.self
        }

        @Test("Flags from rawValue")
        func fromRawValue() {
            let flags = Kernel.Socket.Flags(rawValue: O_NONBLOCK)
            #expect(flags.rawValue == O_NONBLOCK)
        }
    }

    // MARK: - Flag Constants Tests

    extension Kernel.Socket.Flags.Test.Unit {
        @Test("nonBlock flag")
        func nonBlockFlag() {
            let flags = Kernel.Socket.Flags.nonBlock
            #expect(flags.rawValue == O_NONBLOCK)
        }

        @Test("closeOnExec flag")
        func closeOnExecFlag() {
            let flags = Kernel.Socket.Flags.closeOnExec
            #expect(flags.rawValue == O_CLOEXEC)
        }

        @Test("none flag is empty")
        func noneFlag() {
            let flags = Kernel.Socket.Flags.none
            #expect(flags.isEmpty)
            #expect(flags.rawValue == 0)
        }

        @Test("asyncDefault combines nonBlock and closeOnExec")
        func asyncDefaultFlag() {
            let flags = Kernel.Socket.Flags.asyncDefault
            #expect(flags.contains(.nonBlock))
            #expect(flags.contains(.closeOnExec))
        }
    }

    // MARK: - OptionSet Tests

    extension Kernel.Socket.Flags.Test.Unit {
        @Test("Flags can be combined with array literal")
        func flagCombination() {
            let combined: Kernel.Socket.Flags = [.nonBlock, .closeOnExec]
            #expect(combined.contains(.nonBlock))
            #expect(combined.contains(.closeOnExec))
        }

        @Test("Flags contains check")
        func containsCheck() {
            let flags: Kernel.Socket.Flags = [.nonBlock, .closeOnExec]
            #expect(flags.contains(.nonBlock))
            #expect(flags.contains(.closeOnExec))
        }

        @Test("Flags array literal initialization")
        func arrayLiteralInit() {
            let flags: Kernel.Socket.Flags = [.nonBlock, .closeOnExec]
            #expect(flags == .asyncDefault)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.Socket.Flags.Test.Unit {
        @Test("Flags is Sendable")
        func isSendable() {
            let value: any Sendable = Kernel.Socket.Flags.none
            #expect(value is Kernel.Socket.Flags)
        }

        @Test("Flags is Equatable")
        func isEquatable() {
            let a = Kernel.Socket.Flags.nonBlock
            let b = Kernel.Socket.Flags.nonBlock
            let c = Kernel.Socket.Flags.closeOnExec
            #expect(a == b)
            #expect(a != c)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.Socket.Flags.Test.EdgeCase {
        @Test("Empty flags is none")
        func emptyIsNone() {
            let empty: Kernel.Socket.Flags = []
            #expect(empty == .none)
        }

        @Test("Flags rawValue roundtrip")
        func rawValueRoundtrip() {
            let original: Kernel.Socket.Flags = [.nonBlock, .closeOnExec]
            let roundtrip = Kernel.Socket.Flags(rawValue: original.rawValue)
            #expect(roundtrip == original)
        }
    }

#endif
