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

public import Binary

extension Kernel.File.Direct.Requirements {
    /// Concrete alignment values for Direct I/O.
    public struct Alignment: Sendable, Equatable {
        /// Required alignment for buffer memory addresses.
        ///
        /// The buffer pointer passed to read/write must have an address
        /// that is a multiple of this value.
        ///
        /// Typical values: 512 (legacy), 4096 (modern SSDs/NVMe).
        public let bufferAlignment: Binary.Alignment

        /// Required alignment for file offsets.
        ///
        /// The file position for read/write operations must be a multiple
        /// of this value.
        ///
        /// Usually matches `bufferAlignment` but may differ on some systems.
        public let offsetAlignment: Binary.Alignment

        /// Required multiple for I/O transfer lengths.
        ///
        /// The number of bytes read/written must be a multiple of this value.
        /// Partial sector I/O is not allowed in Direct mode.
        ///
        /// Usually matches `bufferAlignment`.
        public let lengthMultiple: Binary.Alignment

        public init(
            bufferAlignment: Binary.Alignment,
            offsetAlignment: Binary.Alignment,
            lengthMultiple: Binary.Alignment
        ) {
            self.bufferAlignment = bufferAlignment
            self.offsetAlignment = offsetAlignment
            self.lengthMultiple = lengthMultiple
        }

        /// Creates alignment with a single value for all requirements.
        ///
        /// Use when buffer, offset, and length all share the same alignment.
        public init(uniform alignment: Binary.Alignment) {
            self.bufferAlignment = alignment
            self.offsetAlignment = alignment
            self.lengthMultiple = alignment
        }
    }
}

// MARK: - Validation

extension Kernel.File.Direct.Requirements.Alignment {
    /// Validates all alignment requirements for an I/O operation.
    ///
    /// - Parameters:
    ///   - bufferAddress: The buffer address.
    ///   - fileOffset: The file offset.
    ///   - transferLength: The transfer length.
    /// - Returns: The first validation failure, or `nil` if all pass.
    public func validate(
        buffer bufferAddress: Kernel.Memory.Address,
        offset fileOffset: Kernel.File.Offset,
        length transferLength: Kernel.File.Size
    ) -> Kernel.File.Direct.Error? {
        if !buffer.isAligned(bufferAddress) {
            return .misalignedBuffer(
                address: bufferAddress,
                required: bufferAlignment
            )
        }
        if !offset.isAligned(fileOffset) {
            return .misalignedOffset(
                offset: fileOffset.rawValue,
                required: offsetAlignment
            )
        }
        if !length.isValid(transferLength) {
            return .invalidLength(
                length: Int(transferLength),
                requiredMultiple: lengthMultiple
            )
        }
        return nil
    }
}
