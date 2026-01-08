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

extension Kernel.File.Stats {
    /// Errors that can occur during stat operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The file descriptor or handle is invalid.
        case handle(Kernel.Descriptor.Validity.Error)

        /// An I/O error occurred while reading file metadata.
        case io(Kernel.IO.Error)

        /// A platform-specific error that doesn't map to a semantic case.
        case platform(Kernel.Error)
    }
}

// MARK: - Stats.Error CustomStringConvertible

extension Kernel.File.Stats.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .handle(let e): return "handle: \(e)"
        case .io(let e): return "io: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}
