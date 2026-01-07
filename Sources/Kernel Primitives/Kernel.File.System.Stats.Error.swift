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

extension Kernel.File.System.Stats {
    /// Error type for filesystem statistics operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        case path(Kernel.Path.Resolution.Error)
        case handle(Kernel.Descriptor.Validity.Error)
        case permission(Kernel.Permission.Error)
        case memory(Kernel.Memory.Error)
        case io(Kernel.IO.Error)
        case platform(Kernel.Error.Unmapped.Error)
    }
}

extension Kernel.File.System.Stats.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .path(let e): return "path: \(e)"
        case .handle(let e): return "handle: \(e)"
        case .permission(let e): return "permission: \(e)"
        case .memory(let e): return "memory: \(e)"
        case .io(let e): return "io: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}

// MARK: - Error Code Mapping

extension Kernel.File.System.Stats.Error {
    @usableFromInline
    internal init(code: Kernel.Error.Code) {
        if let e = Kernel.Path.Resolution.Error(code: code) {
            self = .path(e)
            return
        }
        if let e = Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        if let e = Kernel.Permission.Error(code: code) {
            self = .permission(e)
            return
        }
        if let e = Kernel.Memory.Error(code: code) {
            self = .memory(e)
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
