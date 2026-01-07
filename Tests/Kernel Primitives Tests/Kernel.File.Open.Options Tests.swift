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

extension Kernel.File.Open.Options {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Open.Options.Test.Unit {
    @Test("Options from rawValue")
    func rawValueInit() {
        let options = Kernel.File.Open.Options(rawValue: 1)
        #expect(options.rawValue == 1)
    }
}

// MARK: - Standard Options

extension Kernel.File.Open.Options.Test.Unit {
    @Test("create constant")
    func createConstant() {
        let options = Kernel.File.Open.Options.create
        #expect(options.rawValue == 1 << 0)
    }

    @Test("truncate constant")
    func truncateConstant() {
        let options = Kernel.File.Open.Options.truncate
        #expect(options.rawValue == 1 << 1)
    }

    @Test("append constant")
    func appendConstant() {
        let options = Kernel.File.Open.Options.append
        #expect(options.rawValue == 1 << 2)
    }

    @Test("exclusive constant")
    func exclusiveConstant() {
        let options = Kernel.File.Open.Options.exclusive
        #expect(options.rawValue == 1 << 3)
    }

    @Test("direct constant")
    func directConstant() {
        let options = Kernel.File.Open.Options.direct
        #expect(options.rawValue == 1 << 6)
    }

    @Test("noFollow constant")
    func noFollowConstant() {
        let options = Kernel.File.Open.Options.noFollow
        #expect(options.rawValue == 1 << 8)
    }
}

// MARK: - OptionSet Operations

extension Kernel.File.Open.Options.Test.Unit {
    @Test("options can be combined")
    func combinedOptions() {
        let options: Kernel.File.Open.Options = [.create, .truncate]
        #expect(options.contains(.create))
        #expect(options.contains(.truncate))
    }

    @Test("contains check")
    func containsCheck() {
        let options: Kernel.File.Open.Options = [.create, .exclusive]
        #expect(options.contains(.create))
        #expect(options.contains(.exclusive))
        #expect(!options.contains(.append))
    }

    @Test("empty options")
    func emptyOptions() {
        let options = Kernel.File.Open.Options()
        #expect(!options.contains(.create))
        #expect(!options.contains(.truncate))
    }

    @Test("union of options")
    func unionOptions() {
        let a: Kernel.File.Open.Options = [.create]
        let b: Kernel.File.Open.Options = [.truncate]
        let combined = a.union(b)
        #expect(combined.contains(.create))
        #expect(combined.contains(.truncate))
    }

    @Test("intersection of options")
    func intersectionOptions() {
        let a: Kernel.File.Open.Options = [.create, .truncate]
        let b: Kernel.File.Open.Options = [.truncate, .append]
        let common = a.intersection(b)
        #expect(!common.contains(.create))
        #expect(common.contains(.truncate))
        #expect(!common.contains(.append))
    }
}

// MARK: - POSIX Conversion Tests

#if !os(Windows)
    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    extension Kernel.File.Open.Options.Test.Unit {
        @Test("create maps to O_CREAT")
        func createPosixFlags() {
            let options: Kernel.File.Open.Options = [.create]
            #expect(options.posixFlags & O_CREAT != 0)
        }

        @Test("truncate maps to O_TRUNC")
        func truncatePosixFlags() {
            let options: Kernel.File.Open.Options = [.truncate]
            #expect(options.posixFlags & O_TRUNC != 0)
        }

        @Test("append maps to O_APPEND")
        func appendPosixFlags() {
            let options: Kernel.File.Open.Options = [.append]
            #expect(options.posixFlags & O_APPEND != 0)
        }

        @Test("exclusive maps to O_EXCL")
        func exclusivePosixFlags() {
            let options: Kernel.File.Open.Options = [.exclusive]
            #expect(options.posixFlags & O_EXCL != 0)
        }

        @Test("noFollow maps to O_NOFOLLOW")
        func noFollowPosixFlags() {
            let options: Kernel.File.Open.Options = [.noFollow]
            #expect(options.posixFlags & O_NOFOLLOW != 0)
        }

        @Test("combined options map correctly")
        func combinedPosixFlags() {
            let options: Kernel.File.Open.Options = [.create, .truncate, .exclusive]
            let flags = options.posixFlags
            #expect(flags & O_CREAT != 0)
            #expect(flags & O_TRUNC != 0)
            #expect(flags & O_EXCL != 0)
        }

        @Test("empty options have zero flags")
        func emptyPosixFlags() {
            let options = Kernel.File.Open.Options()
            #expect(options.posixFlags == 0)
        }

        #if os(Linux)
            @Test("direct maps to O_DIRECT on Linux")
            func directPosixFlags() {
                let options: Kernel.File.Open.Options = [.direct]
                #expect(options.posixFlags & O_DIRECT != 0)
            }
        #endif
    }
#endif

// MARK: - Conformances

extension Kernel.File.Open.Options.Test.Unit {
    @Test("Options is Sendable")
    func isSendable() {
        let options: any Sendable = Kernel.File.Open.Options.create
        #expect(options is Kernel.File.Open.Options)
    }

    @Test("Options is Equatable")
    func isEquatable() {
        let a: Kernel.File.Open.Options = [.create]
        let b: Kernel.File.Open.Options = [.create]
        let c: Kernel.File.Open.Options = [.truncate]
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Options is Hashable")
    func isHashable() {
        var set = Set<Kernel.File.Open.Options>()
        set.insert([.create])
        set.insert([.truncate])
        set.insert([.create])  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Open.Options.Test.EdgeCase {
    @Test("all standard options are distinct bits")
    func distinctBits() {
        let options: [Kernel.File.Open.Options] = [
            .create, .truncate, .append, .exclusive, .direct, .noFollow,
        ]
        for i in 0..<options.count {
            for j in (i + 1)..<options.count {
                #expect(options[i].rawValue & options[j].rawValue == 0)
            }
        }
    }

    @Test("common file creation pattern")
    func createTruncatePattern() {
        let options: Kernel.File.Open.Options = [.create, .truncate]
        #expect(options.contains(.create))
        #expect(options.contains(.truncate))
    }

    @Test("exclusive create pattern")
    func exclusiveCreatePattern() {
        let options: Kernel.File.Open.Options = [.create, .exclusive]
        #expect(options.contains(.create))
        #expect(options.contains(.exclusive))
    }
}
