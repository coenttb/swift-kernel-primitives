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

extension Kernel.IO.Read {
    /// Errors that can occur during read operations.
    public enum Error: Swift.Error, Sendable {
        case handle(Kernel.Descriptor.Validity.Error)
        case blocking(Kernel.IO.Blocking.Error)
        case io(Kernel.IO.Error)
        case memory(Kernel.Memory.Error)
        case platform(Kernel.Error.Unmapped.Error)
    }
}

// MARK: - Equatable

extension Kernel.IO.Read.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.handle(let l), .handle(let r)): return l == r
        case (.blocking(let l), .blocking(let r)): return l == r
        case (.io(let l), .io(let r)): return l == r
        case (.memory(let l), .memory(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension Kernel.IO.Read.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .handle(let e): return "handle: \(e)"
        case .blocking(let e): return "blocking: \(e)"
        case .io(let e): return "io: \(e)"
        case .memory(let e): return "memory: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}

// MARK: - Error Code Mapping

extension Kernel.IO.Read.Error {
    @inlinable
    init(code: Kernel.Error.Code) {
        if let e = Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        if let e = Kernel.IO.Blocking.Error(code: code) {
            self = .blocking(e)
            return
        }
        if let e = Kernel.IO.Error(code: code) {
            self = .io(e)
            return
        }
        if let e = Kernel.Memory.Error(code: code) {
            self = .memory(e)
            return
        }
        self = .platform(Kernel.Error.Unmapped.Error(code: code))
    }

    @inlinable
    static func current() -> Self {
        #if os(Windows)
            Self(code: .captureLastError())
        #else
            Self(code: .captureErrno())
        #endif
    }
}
