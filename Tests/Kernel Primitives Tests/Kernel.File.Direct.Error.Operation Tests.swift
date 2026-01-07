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

extension Kernel.File.Direct.Error.Operation {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Error.Operation.Test.Unit {
    @Test("open case exists")
    func openCase() {
        let operation = Kernel.File.Direct.Error.Operation.open
        if case .open = operation {
            // Expected
        } else {
            Issue.record("Expected .open case")
        }
    }

    @Test("cache case exists")
    func cacheCase() {
        let operation = Kernel.File.Direct.Error.Operation.cache(.set)
        if case .cache = operation {
            // Expected
        } else {
            Issue.record("Expected .cache case")
        }
    }

    @Test("sector case exists")
    func sectorCase() {
        let operation = Kernel.File.Direct.Error.Operation.sector(.getSize)
        if case .sector = operation {
            // Expected
        } else {
            Issue.record("Expected .sector case")
        }
    }

    @Test("read case exists")
    func readCase() {
        let operation = Kernel.File.Direct.Error.Operation.read
        if case .read = operation {
            // Expected
        } else {
            Issue.record("Expected .read case")
        }
    }

    @Test("write case exists")
    func writeCase() {
        let operation = Kernel.File.Direct.Error.Operation.write
        if case .write = operation {
            // Expected
        } else {
            Issue.record("Expected .write case")
        }
    }
}

// MARK: - Nested Type Tests

extension Kernel.File.Direct.Error.Operation.Test.Unit {
    @Test("Cache.set case exists")
    func cacheSetCase() {
        let cache = Kernel.File.Direct.Error.Operation.Cache.set
        #expect(cache.rawValue == "set")
    }

    @Test("Cache.clear case exists")
    func cacheClearCase() {
        let cache = Kernel.File.Direct.Error.Operation.Cache.clear
        #expect(cache.rawValue == "clear")
    }

    @Test("Sector.getSize case exists")
    func sectorGetSizeCase() {
        let sector = Kernel.File.Direct.Error.Operation.Sector.getSize
        #expect(sector.rawValue == "getSize")
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Error.Operation.Test.Unit {
    @Test("Operation is Sendable")
    func isSendable() {
        let operation: any Sendable = Kernel.File.Direct.Error.Operation.open
        #expect(operation is Kernel.File.Direct.Error.Operation)
    }

    @Test("Operation is Equatable")
    func isEquatable() {
        let a = Kernel.File.Direct.Error.Operation.open
        let b = Kernel.File.Direct.Error.Operation.open
        let c = Kernel.File.Direct.Error.Operation.read
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Cache is Sendable")
    func cacheIsSendable() {
        let cache: any Sendable = Kernel.File.Direct.Error.Operation.Cache.set
        #expect(cache is Kernel.File.Direct.Error.Operation.Cache)
    }

    @Test("Cache is Equatable")
    func cacheIsEquatable() {
        let a = Kernel.File.Direct.Error.Operation.Cache.set
        let b = Kernel.File.Direct.Error.Operation.Cache.set
        let c = Kernel.File.Direct.Error.Operation.Cache.clear
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Sector is Sendable")
    func sectorIsSendable() {
        let sector: any Sendable = Kernel.File.Direct.Error.Operation.Sector.getSize
        #expect(sector is Kernel.File.Direct.Error.Operation.Sector)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Error.Operation.Test.EdgeCase {
    @Test("all simple operations are distinct")
    func simpleOperationsDistinct() {
        let open = Kernel.File.Direct.Error.Operation.open
        let read = Kernel.File.Direct.Error.Operation.read
        let write = Kernel.File.Direct.Error.Operation.write
        #expect(open != read)
        #expect(read != write)
        #expect(open != write)
    }

    @Test("cache operations with different types are distinct")
    func cacheOperationsDistinct() {
        let cacheSet = Kernel.File.Direct.Error.Operation.cache(.set)
        let cacheClear = Kernel.File.Direct.Error.Operation.cache(.clear)
        #expect(cacheSet != cacheClear)
    }
}
