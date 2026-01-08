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

extension Kernel.Unlink {
    /// Errors that can occur during unlink operations.
    public enum Error: Swift.Error, Sendable {
        case path(Kernel.Path.Resolution.Error)
        case permission(Kernel.Permission.Error)
        case io(Kernel.IO.Error)
        case platform(Kernel.Error)
    }
}

// MARK: - Equatable

extension Kernel.Unlink.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.path(let l), .path(let r)): return l == r
        case (.permission(let l), .permission(let r)): return l == r
        case (.io(let l), .io(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Unlink.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .path(let e): return "path: \(e)"
        case .permission(let e): return "permission: \(e)"
        case .io(let e): return "io: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}

// MARK: - Error Code Mapping

extension Kernel.Unlink.Error {
    @inlinable
    init(code: Kernel.Error.Code) {
        if let e = Kernel.Path.Resolution.Error(code: code) {
            self = .path(e)
            return
        }
        if let e = Kernel.Permission.Error(code: code) {
            self = .permission(e)
            return
        }
        if let e = Kernel.IO.Error(code: code) {
            self = .io(e)
            return
        }
        self = .platform(Kernel.Error(code: code))
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
