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

extension Kernel.File.Open {
    public enum Error: Swift.Error, Sendable {
        case path(Kernel.Path.Resolution.Error)
        case permission(Kernel.Permission.Error)
        case handle(Kernel.Descriptor.Validity.Error)
        case space(Kernel.Storage.Error)
        case io(Kernel.IO.Error)
        case platform(Kernel.Error.Unmapped.Error)
    }
}

extension Kernel.File.Open.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.path(let l), .path(let r)): return l == r
        case (.permission(let l), .permission(let r)): return l == r
        case (.handle(let l), .handle(let r)): return l == r
        case (.space(let l), .space(let r)): return l == r
        case (.io(let l), .io(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

extension Kernel.File.Open.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .path(let e): return "path: \(e)"
        case .permission(let e): return "permission: \(e)"
        case .handle(let e): return "handle: \(e)"
        case .space(let e): return "space: \(e)"
        case .io(let e): return "io: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}

// MARK: - Error Code Mapping

extension Kernel.File.Open.Error {
    @usableFromInline
    internal init(code: Kernel.Error.Code) {
        if let e = Kernel.Path.Resolution.Error(code: code) {
            self = .path(e)
            return
        }
        if let e = Kernel.Permission.Error(code: code) {
            self = .permission(e)
            return
        }
        if let e = Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        if let e = Kernel.Storage.Error(code: code) {
            self = .space(e)
            return
        }
        if let e = Kernel.IO.Error(code: code) {
            self = .io(e)
            return
        }
        self = .platform(Kernel.Error.Unmapped.Error(code: code))
    }

    @usableFromInline
    internal static func current() -> Self {
        #if os(Windows)
            Self(code: .captureLastError())
        #else
            Self(code: .captureErrno())
        #endif
    }
}
