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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif os(Windows)
    public import WinSDK
#endif

extension Kernel.File.Clone {
    /// Errors that can occur during clone operations.
    public enum Error: Swift.Error, Sendable, Equatable, CustomStringConvertible {
        /// Reflink is not supported on this filesystem.
        ///
        /// Returned by `.reflinkOrFail` when the filesystem doesn't support CoW.
        case notSupported

        /// Source and destination are on different filesystems/volumes.
        ///
        /// Reflink requires both paths to be on the same volume.
        case crossDevice

        /// The source file does not exist.
        case sourceNotFound

        /// The destination already exists.
        ///
        /// Clone operations do not overwrite by default.
        case destinationExists

        /// Permission denied for source or destination.
        case permissionDenied

        /// The source is a directory, not a regular file.
        ///
        /// Use a recursive directory clone for directories.
        case isDirectory

        /// A platform-specific error occurred.
        case platform(code: Kernel.Error.Code, operation: Operation)

        public var description: String {
            switch self {
            case .notSupported:
                return "Reflink not supported on this filesystem"
            case .crossDevice:
                return "Source and destination are on different devices"
            case .sourceNotFound:
                return "Source file not found"
            case .destinationExists:
                return "Destination already exists"
            case .permissionDenied:
                return "Permission denied"
            case .isDirectory:
                return "Source is a directory"
            case .platform(let code, let operation):
                return "Platform error \(code) during \(operation)"
            }
        }
    }
}

// MARK: - Error Conversion

extension Kernel.File.Clone.Error {
    /// Creates a semantic error from a raw syscall error.
    public init(from syscall: Syscall) {
        switch syscall {
        case .notSupported:
            self = .notSupported

        case .platform(let code, let operation):
            self.init(code: code, operation: operation)
        }
    }

    /// Maps platform error code to semantic error.
    private init(code: Kernel.Error.Code, operation: Operation) {
        switch code {
        case .posix(let errno):
            #if !os(Windows)
                switch errno {
                case ENOENT:
                    self = .sourceNotFound
                case EEXIST:
                    self = .destinationExists
                case EACCES, EPERM:
                    self = .permissionDenied
                case EXDEV:
                    self = .crossDevice
                case EISDIR:
                    self = .isDirectory
                case ENOTSUP, EOPNOTSUPP:
                    self = .notSupported
                default:
                    self = .platform(code: code, operation: operation)
                }
            #else
                self = .platform(code: code, operation: operation)
            #endif

        case .win32(let error):
            #if os(Windows)
                switch error {
                case 2:  // ERROR_FILE_NOT_FOUND
                    self = .sourceNotFound
                case 80:  // ERROR_FILE_EXISTS
                    self = .destinationExists
                case 5:  // ERROR_ACCESS_DENIED
                    self = .permissionDenied
                case 17:  // ERROR_NOT_SAME_DEVICE
                    self = .crossDevice
                default:
                    self = .platform(code: code, operation: operation)
                }
            #else
                self = .platform(code: code, operation: operation)
            #endif
        }
    }
}
