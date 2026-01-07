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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif os(Windows)
    public import WinSDK
#endif

extension Kernel.File.Direct {
    /// Errors that can occur during Direct I/O operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Direct I/O is not supported on this platform or filesystem.
        ///
        /// This occurs when:
        /// - Using `.direct` mode on macOS (use `.uncached` instead)
        /// - The filesystem doesn't support `O_DIRECT` or `NO_BUFFERING`
        /// - Requirements are `.unknown` and cannot be determined
        case notSupported

        /// The buffer memory address is not properly aligned.
        ///
        /// Direct I/O requires the buffer to be aligned to the sector size.
        /// Use `Buffer.Aligned` for portable aligned allocation.
        case misalignedBuffer(address: Kernel.Memory.Address, required: Binary.Alignment)

        /// The file offset is not properly aligned.
        ///
        /// Direct I/O requires file offsets to be multiples of the sector size.
        case misalignedOffset(offset: Int64, required: Binary.Alignment)

        /// The I/O length is not a valid multiple of the sector size.
        ///
        /// Direct I/O requires transfer lengths to be exact multiples.
        case invalidLength(length: Int, requiredMultiple: Binary.Alignment)

        /// Failed to enable or disable cache bypass mode.
        case modeChange

        /// The file handle is not valid or not open for the requested operation.
        case invalidHandle

        /// Platform-specific error with error code.
        case platform(code: Kernel.Error.Code, operation: Operation)
    }
}

// MARK: - CustomStringConvertible

extension Kernel.File.Direct.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notSupported:
            return "Direct I/O not supported"
        case .misalignedBuffer(let address, let required):
            return "Buffer address \(address) not aligned to \(required)"
        case .misalignedOffset(let offset, let required):
            return "File offset \(offset) not aligned to \(required) bytes"
        case .invalidLength(let length, let requiredMultiple):
            return "Length \(length) is not a multiple of \(requiredMultiple)"
        case .modeChange:
            return "Failed to change cache mode"
        case .invalidHandle:
            return "Invalid file handle"
        case .platform(let code, let operation):
            return "Platform error \(code) during \(operation)"
        }
    }
}

// MARK: - Translation from Syscall

extension Kernel.File.Direct.Error {
    /// Creates a semantic error from a raw syscall error.
    package init(from syscall: Syscall) {
        switch syscall {
        case .invalidDescriptor:
            self = .invalidHandle

        case .alignmentViolation(let operation):
            // Alignment violation during the operation
            self = .platform(code: .posix(-1), operation: operation)

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
                case EINVAL:
                    // EINVAL from O_DIRECT often means alignment violation
                    self = .platform(code: code, operation: operation)
                case EBADF:
                    self = .invalidHandle
                case ENOTSUP, EOPNOTSUPP:
                    self = .notSupported
                case EACCES, EPERM:
                    self = .platform(code: code, operation: operation)
                default:
                    self = .platform(code: code, operation: operation)
                }
            #else
                self = .platform(code: code, operation: operation)
            #endif

        case .win32(let error):
            #if os(Windows)
                switch error {
                case UInt32(ERROR_INVALID_PARAMETER):
                    self = .platform(code: code, operation: operation)
                case UInt32(ERROR_INVALID_HANDLE):
                    self = .invalidHandle
                case UInt32(ERROR_NOT_SUPPORTED):
                    self = .notSupported
                case UInt32(ERROR_ACCESS_DENIED):
                    self = .platform(code: code, operation: operation)
                default:
                    self = .platform(code: code, operation: operation)
                }
            #else
                self = .platform(code: code, operation: operation)
            #endif
        }
    }
}
