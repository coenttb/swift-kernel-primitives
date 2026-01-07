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

extension Kernel.Memory.Map.Protection {
    #TestSuites
}

// MARK: - Protection Tests

#if !os(Windows)

    extension Kernel.Memory.Map.Protection.Test.Unit {
        @Test("none has zero raw value")
        func noneHasZeroRawValue() {
            #expect(Kernel.Memory.Map.Protection.none.rawValue == 0)
        }

        @Test("read write execute are distinct")
        func readWriteExecuteDistinct() {
            let read = Kernel.Memory.Map.Protection.read
            let write = Kernel.Memory.Map.Protection.write
            let execute = Kernel.Memory.Map.Protection.execute

            #expect(read != write)
            #expect(read != execute)
            #expect(write != execute)
        }

        @Test("bitwise OR combines flags")
        func bitwiseOrCombinesFlags() {
            let read = Kernel.Memory.Map.Protection.read
            let write = Kernel.Memory.Map.Protection.write
            let combined = read | write

            #expect(combined.rawValue == (read.rawValue | write.rawValue))
        }

        @Test("contains checks flag presence")
        func containsChecksFlagPresence() {
            let read = Kernel.Memory.Map.Protection.read
            let write = Kernel.Memory.Map.Protection.write
            let combined = read | write

            #expect(combined.contains(.read))
            #expect(combined.contains(.write))
            #expect(!combined.contains(.execute))
        }

        @Test("readWrite is read OR write")
        func readWriteIsReadOrWrite() {
            let readWrite = Kernel.Memory.Map.Protection.readWrite
            let manual = Kernel.Memory.Map.Protection.read | .write

            #expect(readWrite == manual)
            #expect(readWrite.contains(.read))
            #expect(readWrite.contains(.write))
        }

        @Test("none contains nothing")
        func noneContainsNothing() {
            let none = Kernel.Memory.Map.Protection.none

            #expect(!none.contains(.read))
            #expect(!none.contains(.write))
            #expect(!none.contains(.execute))
        }

        @Test("Protection is Equatable")
        func protectionIsEquatable() {
            let a = Kernel.Memory.Map.Protection.read
            let b = Kernel.Memory.Map.Protection.read
            let c = Kernel.Memory.Map.Protection.write

            #expect(a == b)
            #expect(a != c)
        }

        @Test("Protection is Hashable")
        func protectionIsHashable() {
            var set = Set<Kernel.Memory.Map.Protection>()
            set.insert(.read)
            set.insert(.write)
            set.insert(.read)  // duplicate

            #expect(set.count == 2)
            #expect(set.contains(.read))
            #expect(set.contains(.write))
        }
    }

#endif
