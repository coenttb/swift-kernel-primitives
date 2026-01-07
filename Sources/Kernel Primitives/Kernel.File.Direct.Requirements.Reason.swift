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

extension Kernel.File.Direct.Requirements {
    /// Reason why requirements could not be determined.
    public enum Reason: Sendable, Equatable, CustomStringConvertible {
        /// The platform does not support strict Direct I/O.
        ///
        /// macOS only supports `.uncached` mode (best-effort hint).
        case platformUnsupported

        /// The storage device's sector size could not be determined.
        ///
        /// On Windows, this occurs when `GetDiskFreeSpaceW` fails
        /// (e.g., network filesystems, unusual volume configurations).
        case sectorSizeUndetermined

        /// The filesystem does not support Direct I/O.
        ///
        /// Some filesystems (e.g., certain network filesystems, FUSE)
        /// may not support `O_DIRECT` or `NO_BUFFERING`.
        case filesystemUnsupported

        /// The file handle is not suitable for Direct I/O.
        case invalidHandle

        public var description: String {
            switch self {
            case .platformUnsupported:
                return "Platform does not support strict Direct I/O"
            case .sectorSizeUndetermined:
                return "Could not determine sector size"
            case .filesystemUnsupported:
                return "Filesystem does not support Direct I/O"
            case .invalidHandle:
                return "Invalid file handle"
            }
        }
    }
}
