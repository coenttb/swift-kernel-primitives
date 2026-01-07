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

extension Kernel.File.Handle {
    /// Errors that can occur during file handle operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The file handle is invalid or closed.
        case invalidHandle

        /// End of file reached.
        case endOfFile

        /// The operation was interrupted.
        case interrupted

        /// No space left on device.
        case noSpace

        /// Buffer alignment violation for Direct I/O (detected by pre-validation).
        case misalignedBuffer(address: Kernel.Memory.Address, required: Binary.Alignment)

        /// Offset alignment violation for Direct I/O (detected by pre-validation).
        case misalignedOffset(offset: Int64, required: Binary.Alignment)

        /// Length not a multiple of required granularity (detected by pre-validation).
        case invalidLength(length: Int, requiredMultiple: Binary.Alignment)

        /// Direct I/O requirements are unknown.
        case requirementsUnknown

        /// Alignment violation or Direct I/O not supported (detected by kernel).
        ///
        /// This error occurs when the kernel rejects an I/O operation with `EINVAL`
        /// (POSIX) or `ERROR_INVALID_PARAMETER` (Windows). In Direct I/O mode,
        /// this typically indicates:
        ///
        /// - Buffer address not aligned to required boundary
        /// - File offset not aligned
        /// - Transfer length not a multiple of sector/block size
        /// - Direct I/O not supported by the filesystem/device
        ///
        /// **Note:** This error may occur even if pre-validation passed, because
        /// alignment requirements are not always reliably discoverable, especially
        /// on Linux. See `Kernel.File.Direct.requirements(for:)` documentation.
        case alignmentViolation(operation: Operation)

        /// Platform-specific error.
        case platform(code: Kernel.Error.Code, operation: Operation)
    }
}

// MARK: - Error Construction

#if !os(Windows)
    extension Kernel.File.Handle.Error {
        /// Creates an error from a POSIX errno.
        package init(posixErrno: Int32, operation: Kernel.File.Handle.Operation) {
            switch posixErrno {
            case EBADF:
                self = .invalidHandle
            case EINTR:
                self = .interrupted
            case ENOSPC:
                self = .noSpace
            case EINVAL:
                // EINVAL during I/O typically means alignment violation for Direct I/O
                // or unsupported operation. Map to semantic error for stable diagnostics.
                self = .alignmentViolation(operation: operation)
            default:
                self = .platform(code: .posix(posixErrno), operation: operation)
            }
        }
    }
#endif

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#endif

#if os(Windows)
    public import WinSDK

    extension Kernel.File.Handle.Error {
        /// Creates an error from a Windows error code.
        package init(windowsError: UInt32, operation: Kernel.File.Handle.Operation) {
            switch windowsError {
            case DWORD(ERROR_INVALID_HANDLE):
                self = .invalidHandle
            case DWORD(ERROR_DISK_FULL), DWORD(ERROR_HANDLE_DISK_FULL):
                self = .noSpace
            case DWORD(ERROR_INVALID_PARAMETER):
                // ERROR_INVALID_PARAMETER during I/O typically means alignment violation
                // for FILE_FLAG_NO_BUFFERING. Map to semantic error.
                self = .alignmentViolation(operation: operation)
            default:
                self = .platform(code: .win32(UInt32(windowsError)), operation: operation)
            }
        }
    }
#endif

// MARK: - From Direct Error

extension Kernel.File.Handle.Error {
    /// Creates a handle error from a Direct I/O error.
    package init(from directError: Kernel.File.Direct.Error) {
        switch directError {
        case .notSupported:
            self = .requirementsUnknown
        case .misalignedBuffer(let address, let required):
            self = .misalignedBuffer(address: address, required: required)
        case .misalignedOffset(let offset, let required):
            self = .misalignedOffset(offset: offset, required: required)
        case .invalidLength(let length, let requiredMultiple):
            self = .invalidLength(length: length, requiredMultiple: requiredMultiple)
        case .modeChange:
            self = .platform(code: .posix(-1), operation: .sync)
        case .invalidHandle:
            self = .invalidHandle
        case .platform(let code, let operation):
            // Map Direct.Error operation to Handle.Error operation
            switch operation {
            case .open:
                self = .platform(code: code, operation: .read)
            case .cache, .sector:
                self = .platform(code: code, operation: .sync)
            case .read:
                self = .platform(code: code, operation: .read)
            case .write:
                self = .platform(code: code, operation: .write)
            }
        }
    }
}

// MARK: - From Kernel.IO.Read.Error

extension Kernel.File.Handle.Error {
    /// Creates an IO handle error from a Kernel read error.
    package init(from error: Kernel.IO.Read.Error, operation: Kernel.File.Handle.Operation) {
        switch error {
        case .handle(let handleError):
            switch handleError {
            case .invalid, .limit:
                self = .invalidHandle
            }

        case .blocking:
            self = .platform(code: .posix(-1), operation: operation)

        case .io:
            self = .platform(code: .posix(-1), operation: operation)

        case .memory:
            self = .alignmentViolation(operation: operation)

        case .platform:
            self = .platform(code: .posix(-1), operation: operation)
        }
    }
}

// MARK: - From Kernel.IO.Write.Error

extension Kernel.File.Handle.Error {
    /// Creates an IO handle error from a Kernel write error.
    package init(from error: Kernel.IO.Write.Error, operation: Kernel.File.Handle.Operation) {
        switch error {
        case .handle(let handleError):
            switch handleError {
            case .invalid, .limit:
                self = .invalidHandle
            }

        case .blocking:
            self = .platform(code: .posix(-1), operation: operation)

        case .io:
            self = .platform(code: .posix(-1), operation: operation)

        case .space(let spaceError):
            switch spaceError {
            case .exhausted, .quota:
                self = .noSpace
            }

        case .memory:
            self = .alignmentViolation(operation: operation)

        case .platform:
            self = .platform(code: .posix(-1), operation: operation)
        }
    }
}

// MARK: - CustomStringConvertible

extension Kernel.File.Handle.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidHandle:
            return "Invalid file handle"
        case .endOfFile:
            return "End of file"
        case .interrupted:
            return "Operation interrupted"
        case .noSpace:
            return "No space left on device"
        case .misalignedBuffer(let address, let required):
            return "Buffer address \(address) not aligned to \(required)"
        case .misalignedOffset(let offset, let required):
            return "File offset \(offset) not aligned to \(required) bytes"
        case .invalidLength(let length, let requiredMultiple):
            return "Length \(length) is not a multiple of \(requiredMultiple)"
        case .requirementsUnknown:
            return "Direct I/O requirements unknown"
        case .alignmentViolation(let operation):
            return "Alignment violation or Direct I/O not supported during \(operation.rawValue)"
        case .platform(let code, let operation):
            return "Platform error \(code) during \(operation.rawValue)"
        }
    }
}
