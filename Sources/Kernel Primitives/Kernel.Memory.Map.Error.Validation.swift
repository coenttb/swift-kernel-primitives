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

extension Kernel.Memory.Map.Error {
    /// Validation failure reasons.
    public enum Validation: Sendable, Equatable, Hashable {
        /// Length must be greater than zero.
        case length
        /// Address alignment is invalid.
        case alignment
        /// Offset is invalid.
        case offset
    }
}

extension Kernel.Memory.Map.Error.Validation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .length: return "length must be greater than zero"
        case .alignment: return "address alignment is invalid"
        case .offset: return "offset is invalid"
        }
    }
}
