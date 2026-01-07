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
    /// File type.
    public enum Kind: Sendable, Equatable, Hashable {
        /// Regular file.
        case regular

        /// Directory.
        case directory

        /// Symbolic link.
        case link(Link)

        /// Device (block or character, POSIX only).
        case device(Device)

        /// Named pipe/FIFO (POSIX only).
        case fifo

        /// Socket (POSIX only).
        case socket

        /// Unknown or unsupported file type.
        case unknown
    }
}
