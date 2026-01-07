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

internal import Dimension

// MARK: - Read Type

extension Kernel.IO {
    /// Read operations.
    public enum Read: Sendable {

    }
}

// MARK: - POSIX Implementation

#if !os(Windows)

    #if canImport(Darwin)
        public import Darwin
    #elseif canImport(Glibc)
        public import Glibc
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.IO.Read {
        /// Reads bytes from a file descriptor.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor to read from.
        ///   - buffer: The buffer to read into.
        /// - Returns: Number of bytes read. Returns 0 on EOF.
        /// - Throws: `Kernel.IO.Read.Error` on failure.
        @inlinable
        public static func read(
            _ descriptor: Kernel.Descriptor,
            into buffer: UnsafeMutableRawBufferPointer
        ) throws(Error) -> Int {
            guard let baseAddress = buffer.baseAddress else {
                return 0
            }
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }
            #if canImport(Darwin)
                return try Kernel.Syscall.require(
                    Darwin.read(descriptor.rawValue, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #elseif canImport(Glibc)
                return try Kernel.Syscall.require(
                    Glibc.read(descriptor.rawValue, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #elseif canImport(Musl)
                return try Kernel.Syscall.require(
                    Musl.read(descriptor.rawValue, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #endif
        }

        /// Reads bytes from a file descriptor at a specific offset.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor to read from.
        ///   - buffer: The buffer to read into.
        ///   - offset: The file offset to read from.
        /// - Returns: Number of bytes read. Returns 0 on EOF.
        /// - Throws: `Kernel.IO.Read.Error` on failure.
        @inlinable
        public static func pread(
            _ descriptor: Kernel.Descriptor,
            into buffer: UnsafeMutableRawBufferPointer,
            at offset: Kernel.File.Offset
        ) throws(Error) -> Int {
            guard let baseAddress = buffer.baseAddress else {
                return 0
            }
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }
            #if canImport(Darwin)
                return try Kernel.Syscall.require(
                    Darwin.pread(descriptor.rawValue, baseAddress, buffer.count, off_t(offset.rawValue)),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #elseif canImport(Glibc)
                return try Kernel.Syscall.require(
                    Glibc.pread(descriptor.rawValue, baseAddress, buffer.count, off_t(offset.rawValue)),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #elseif canImport(Musl)
                return try Kernel.Syscall.require(
                    Musl.pread(descriptor.rawValue, baseAddress, buffer.count, off_t(offset.rawValue)),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #endif
        }
    }

#endif

// MARK: - Span Adapters

extension Kernel.IO.Read {
    /// Reads bytes from a file descriptor into a mutable span.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - span: The mutable span to read into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    @inlinable
    public static func read(
        _ descriptor: Kernel.Descriptor,
        into span: inout MutableSpan<UInt8>
    ) throws(Error) -> Int {
        try span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int in
            try read(descriptor, into: buffer)
        }
    }

    /// Reads bytes from a file descriptor at a specific offset into a mutable span.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - span: The mutable span to read into.
    ///   - offset: The file offset to read from.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    @inlinable
    public static func pread(
        _ descriptor: Kernel.Descriptor,
        into span: inout MutableSpan<UInt8>,
        at offset: Kernel.File.Offset
    ) throws(Error) -> Int {
        try span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int in
            try pread(descriptor, into: buffer, at: offset)
        }
    }
}

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.IO.Read {
        /// Reads bytes from a file handle.
        @inlinable
        public static func read(
            _ descriptor: Kernel.Descriptor,
            into buffer: UnsafeMutableRawBufferPointer
        ) throws(Error) -> Int {
            guard let baseAddress = buffer.baseAddress else {
                return 0
            }
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }

            var bytesRead: DWORD = 0
            let result = ReadFile(
                descriptor.rawValue,
                baseAddress,
                DWORD(min(buffer.count, Int(DWORD.max))),
                &bytesRead,
                nil
            )

            guard result else {
                let error = GetLastError()
                if error == DWORD(ERROR_HANDLE_EOF) {
                    return 0
                }
                throw Self.Error(code: .win32(error))
            }
            return Int(bytesRead)
        }

        /// Reads bytes from a file handle at a specific offset.
        @inlinable
        public static func pread(
            _ descriptor: Kernel.Descriptor,
            into buffer: UnsafeMutableRawBufferPointer,
            at offset: Kernel.File.Offset
        ) throws(Error) -> Int {
            guard let baseAddress = buffer.baseAddress else {
                return 0
            }
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }

            var overlapped = OVERLAPPED()
            overlapped.Offset = DWORD(offset.rawValue & 0xFFFF_FFFF)
            overlapped.OffsetHigh = DWORD(offset.rawValue >> 32)

            var bytesRead: DWORD = 0
            let result = ReadFile(
                descriptor.rawValue,
                baseAddress,
                DWORD(min(buffer.count, Int(DWORD.max))),
                &bytesRead,
                &overlapped
            )

            guard result else {
                let error = GetLastError()
                if error == DWORD(ERROR_HANDLE_EOF) {
                    return 0
                }
                throw Self.Error(code: .win32(error))
            }
            return Int(bytesRead)
        }
    }

#endif
