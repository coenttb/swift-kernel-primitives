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
#elseif canImport(Musl)
    internal import Musl
#elseif os(Windows)
    @preconcurrency public import WinSDK
#endif

extension Kernel {
    /// File position seeking operations.
    public enum Seek: Sendable {}
}

// MARK: - Origin (POSIX conversion)

#if !os(Windows)
    extension Kernel.Seek.Origin {
        /// Converts to the POSIX whence constant.
        var posixWhence: Int32 {
            switch self {
            case .start: return SEEK_SET
            case .current: return SEEK_CUR
            case .end: return SEEK_END
            }
        }
    }
#endif

// MARK: - Error

extension Kernel.Seek {
    /// Errors that can occur during seek operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The file descriptor is invalid.
        case invalidDescriptor

        /// The resulting offset would be negative.
        case negativeOffset

        /// The file descriptor refers to a pipe, socket, or FIFO.
        case notSeekable

        /// The resulting offset is too large for the file.
        case overflow

        /// Platform-specific error.
        case platform(code: Kernel.Error.Code)
    }
}

#if !os(Windows)
    extension Kernel.Seek.Error {
        /// Creates an error from a POSIX errno value.
        init(posixErrno: Int32) {
            switch posixErrno {
            case EBADF:
                self = .invalidDescriptor
            case EINVAL:
                self = .negativeOffset
            case ESPIPE:
                self = .notSeekable
            case EOVERFLOW:
                self = .overflow
            default:
                self = .platform(code: .posix(posixErrno))
            }
        }
    }
#endif

// MARK: - CustomStringConvertible

extension Kernel.Seek.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidDescriptor:
            return "Invalid file descriptor"
        case .negativeOffset:
            return "Resulting offset would be negative"
        case .notSeekable:
            return "File descriptor is not seekable (pipe, socket, or FIFO)"
        case .overflow:
            return "Resulting offset would overflow"
        case .platform(let code):
            return "Seek failed: \(code)"
        }
    }
}

// MARK: - Seek Operations

#if !os(Windows)
    extension Kernel.Seek {
        /// Repositions the file offset.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor.
        ///   - offset: The offset value.
        ///   - origin: The reference point for the offset.
        /// - Returns: The resulting absolute offset from the beginning of the file.
        /// - Throws: `Kernel.Seek.Error` on failure.
        public static func perform(
            _ descriptor: Kernel.File.Descriptor,
            offset: Kernel.File.Offset,
            from origin: Origin
        ) throws(Error) -> Kernel.File.Offset {
            let result = lseek(descriptor.rawValue, off_t(offset.rawValue), origin.posixWhence)
            guard result != -1 else {
                throw Error(posixErrno: errno)
            }
            return Kernel.File.Offset(result)
        }

        /// Seeks to the beginning of the file.
        ///
        /// - Parameter descriptor: The file descriptor.
        /// - Returns: The offset (always 0 on success).
        /// - Throws: `Kernel.Seek.Error` on failure.
        public static func toStart(
            _ descriptor: Kernel.File.Descriptor
        ) throws(Error) -> Kernel.File.Offset {
            try perform(descriptor, offset: 0, from: .start)
        }

        /// Returns the current file offset.
        ///
        /// - Parameter descriptor: The file descriptor.
        /// - Returns: The current offset from the beginning of the file.
        /// - Throws: `Kernel.Seek.Error` on failure.
        public static func toCurrent(
            _ descriptor: Kernel.File.Descriptor
        ) throws(Error) -> Kernel.File.Offset {
            try perform(descriptor, offset: 0, from: .current)
        }

        /// Seeks to the end of the file.
        ///
        /// - Parameter descriptor: The file descriptor.
        /// - Returns: The offset at the end of the file (i.e., the file size).
        /// - Throws: `Kernel.Seek.Error` on failure.
        public static func toEnd(
            _ descriptor: Kernel.File.Descriptor
        ) throws(Error) -> Kernel.File.Offset {
            try perform(descriptor, offset: 0, from: .end)
        }
    }
#endif

#if os(Windows)
    extension Kernel.Seek {
        /// Repositions the file offset.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor (HANDLE).
        ///   - offset: The offset value.
        ///   - origin: The reference point for the offset.
        /// - Returns: The resulting absolute offset from the beginning of the file.
        /// - Throws: `Kernel.Seek.Error` on failure.
        public static func perform(
            _ descriptor: Kernel.File.Descriptor,
            offset: Kernel.File.Offset,
            from origin: Origin
        ) throws(Error) -> Kernel.File.Offset {
            var distanceToMove = LARGE_INTEGER()
            distanceToMove.QuadPart = offset.rawValue

            var newPosition = LARGE_INTEGER()

            let moveMethod: DWORD
            switch origin {
            case .start: moveMethod = DWORD(FILE_BEGIN)
            case .current: moveMethod = DWORD(FILE_CURRENT)
            case .end: moveMethod = DWORD(FILE_END)
            }

            let result = SetFilePointerEx(
                descriptor.rawValue,
                distanceToMove,
                &newPosition,
                moveMethod
            )

            guard result else {
                let error = GetLastError()
                switch error {
                case DWORD(ERROR_INVALID_HANDLE):
                    throw .invalidDescriptor
                case DWORD(ERROR_NEGATIVE_SEEK):
                    throw .negativeOffset
                default:
                    throw .platform(code: .win32(error))
                }
            }

            return Kernel.File.Offset(newPosition.QuadPart)
        }

        /// Seeks to the beginning of the file.
        public static func toStart(
            _ descriptor: Kernel.File.Descriptor
        ) throws(Error) -> Kernel.File.Offset {
            try perform(descriptor, offset: 0, from: .start)
        }

        /// Returns the current file offset.
        public static func toCurrent(
            _ descriptor: Kernel.File.Descriptor
        ) throws(Error) -> Kernel.File.Offset {
            try perform(descriptor, offset: 0, from: .current)
        }

        /// Seeks to the end of the file.
        public static func toEnd(
            _ descriptor: Kernel.File.Descriptor
        ) throws(Error) -> Kernel.File.Offset {
            try perform(descriptor, offset: 0, from: .end)
        }
    }
#endif
