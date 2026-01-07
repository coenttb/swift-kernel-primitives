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

extension Kernel.Memory.Map {
    /// Errors from mmap operations.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Failed to map memory.
        case map(Kernel.Error.Code)

        /// Failed to unmap memory.
        case unmap(Kernel.Error.Code)

        /// Failed to sync memory to disk.
        case sync(Kernel.Error.Code)

        /// Failed to change memory protection.
        case protect(Kernel.Error.Code)

        /// Invalid argument.
        case invalid(Validation)
    }
}

extension Kernel.Memory.Map.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .map(let code):
            return "mmap failed (\(code))"
        case .unmap(let code):
            return "munmap failed (\(code))"
        case .sync(let code):
            return "msync failed (\(code))"
        case .protect(let code):
            return "mprotect failed (\(code))"
        case .invalid(let validation):
            return "invalid argument: \(validation)"
        }
    }
}
