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

internal import Binary

extension Kernel.File.Direct.Requirements.Alignment {
    /// Accessor for buffer alignment validation.
    public struct Buffer: Sendable {
        let alignment: Kernel.File.Direct.Requirements.Alignment

        /// Validates that a buffer address is properly aligned.
        ///
        /// - Parameter address: The memory address to validate.
        /// - Returns: `true` if the address is aligned to `bufferAlignment`.
        public func isAligned(_ address: Kernel.Memory.Address) -> Bool {
            alignment.bufferAlignment.isAligned(address)
        }
    }

    /// Accessor for buffer alignment validation.
    public var buffer: Buffer { Buffer(alignment: self) }
}
