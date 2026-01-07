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

extension Kernel.Copy {
    /// Errors from copy operations.
    ///
    /// Each case represents a specific failure mode of `copy_file_range`,
    /// `clone` (FICLONE), or `clonefile`.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Invalid file descriptor.
        /// - POSIX: `EBADF`
        case invalidDescriptor

        /// Cross-device copy not supported.
        /// - POSIX: `EXDEV`
        ///
        /// The source and destination are on different filesystems.
        case crossDevice

        /// Operation not supported.
        /// - POSIX: `EINVAL`, `ENOTSUP`, `EOPNOTSUPP`
        ///
        /// The filesystem or file type doesn't support this operation.
        case unsupported

        /// No space left on device.
        /// - POSIX: `ENOSPC`
        case noSpace

        /// Physical I/O error.
        /// - POSIX: `EIO`
        case io

        /// Permission denied.
        /// - POSIX: `EACCES`, `EPERM`
        case permissionDenied
    }
}

extension Kernel.Copy.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidDescriptor: return "invalid file descriptor"
        case .crossDevice: return "cross-device copy not supported"
        case .unsupported: return "operation not supported"
        case .noSpace: return "no space left on device"
        case .io: return "I/O error"
        case .permissionDenied: return "permission denied"
        }
    }
}

// MARK: - POSIX Error Mapping

#if !os(Windows)

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Kernel.Copy.Error {
        @usableFromInline
        init(posix code: Int32) {
            switch code {
            case EBADF:
                self = .invalidDescriptor
            case EXDEV:
                self = .crossDevice
            case EINVAL, ENOTSUP, EOPNOTSUPP:
                self = .unsupported
            case ENOSPC:
                self = .noSpace
            case EIO:
                self = .io
            case EACCES, EPERM:
                self = .permissionDenied
            default:
                // Map unknown errors to unsupported as a fallback
                self = .unsupported
            }
        }
    }

#endif
