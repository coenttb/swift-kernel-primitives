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

// MARK: - Write Type

extension Kernel.IO {
    /// Write operations for file descriptors.
    ///
    /// Provides both sequential (`write`) and positional (`pwrite`) write operations.
    /// Sequential writes advance the file offset; positional writes leave it unchanged.
    ///
    /// ## Partial Writes
    /// All write operations may return fewer bytes than requested. This is normal behavior,
    /// not an error. Callers should loop until all data is written or an error occurs.
    /// Common causes of partial writes: signals, pipe/socket buffer limits, disk quotas.
    ///
    /// ## Threading
    /// - **Sequential writes** (`write`): Share the file offset. Concurrent sequential writes
    ///   to the same descriptor require external synchronization.
    /// - **Positional writes** (`pwrite`): Do not affect file offset. Safe to use concurrently
    ///   from multiple threads if writing to non-overlapping regions.
    public enum Write: Sendable {

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

    extension Kernel.IO.Write {
        /// Writes bytes to a file descriptor at the current file offset.
        ///
        /// ## Threading
        /// This call blocks until at least one byte is written or an error occurs.
        /// The file offset is advanced by the number of bytes written. Concurrent
        /// sequential writes require external synchronization.
        ///
        /// ## Partial Writes
        /// May return fewer bytes than `buffer.count`. This is not an error—loop until
        /// all data is written. Returns 0 only for zero-length buffers.
        ///
        /// ## Errors
        /// - ``Error/handle(_:)``: Invalid descriptor
        /// - ``Error/io(_:)``: Physical I/O error
        /// - ``Error/noSpace``: Filesystem full
        /// - ``Error/pipe``: Write to pipe/socket with no readers (also raises SIGPIPE)
        /// - ``Error/wouldBlock``: Non-blocking descriptor would block
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor to write to.
        ///   - buffer: The buffer to write from.
        /// - Returns: Number of bytes written (may be less than `buffer.count`).
        /// - Throws: ``Kernel/IO/Write/Error`` on failure.
        @inlinable
        public static func write(
            _ descriptor: Kernel.Descriptor,
            from buffer: UnsafeRawBufferPointer
        ) throws(Error) -> Int {
            guard let baseAddress = buffer.baseAddress else {
                return 0
            }
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }
            #if canImport(Darwin)
                return try Kernel.Syscall.require(
                    Darwin.write(descriptor.rawValue, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #elseif canImport(Glibc)
                return try Kernel.Syscall.require(
                    Glibc.write(descriptor.rawValue, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #elseif canImport(Musl)
                return try Kernel.Syscall.require(
                    Musl.write(descriptor.rawValue, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #endif
        }

        /// Writes bytes to a file descriptor at a specific offset without changing the file position.
        ///
        /// ## Threading
        /// This call blocks until at least one byte is written or an error occurs.
        /// The file offset is **not** modified. Safe for concurrent use from multiple
        /// threads when writing to non-overlapping regions.
        ///
        /// ## Partial Writes
        /// May return fewer bytes than `buffer.count`. This is not an error—loop until
        /// all data is written, adjusting the offset accordingly.
        ///
        /// ## Errors
        /// - ``Error/handle(_:)``: Invalid descriptor
        /// - ``Error/io(_:)``: Physical I/O error
        /// - ``Error/noSpace``: Filesystem full
        /// - ``Error/invalidSeek``: Descriptor does not support seeking (pipes, sockets)
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor to write to.
        ///   - buffer: The buffer to write from.
        ///   - offset: The file offset to write at.
        /// - Returns: Number of bytes written (may be less than `buffer.count`).
        /// - Throws: ``Kernel/IO/Write/Error`` on failure.
        @inlinable
        public static func pwrite(
            _ descriptor: Kernel.Descriptor,
            from buffer: UnsafeRawBufferPointer,
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
                    Darwin.pwrite(descriptor.rawValue, baseAddress, buffer.count, off_t(offset.rawValue)),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #elseif canImport(Glibc)
                return try Kernel.Syscall.require(
                    Glibc.pwrite(descriptor.rawValue, baseAddress, buffer.count, off_t(offset.rawValue)),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #elseif canImport(Musl)
                return try Kernel.Syscall.require(
                    Musl.pwrite(descriptor.rawValue, baseAddress, buffer.count, off_t(offset.rawValue)),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #endif
        }
    }

#endif

// MARK: - Span Adapters

extension Kernel.IO.Write {
    /// Writes bytes from a span to a file descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - span: The span containing bytes to write.
    /// - Returns: Number of bytes written.
    /// - Throws: `Kernel.IO.Write.Error` on failure.
    @inlinable
    public static func write(
        _ descriptor: Kernel.Descriptor,
        from span: Span<UInt8>
    ) throws(Error) -> Int {
        try span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
            try write(descriptor, from: buffer)
        }
    }

    /// Writes bytes from a span to a file descriptor at a specific offset.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - span: The span containing bytes to write.
    ///   - offset: The file offset to write at.
    /// - Returns: Number of bytes written.
    /// - Throws: `Kernel.IO.Write.Error` on failure.
    @inlinable
    public static func pwrite(
        _ descriptor: Kernel.Descriptor,
        from span: Span<UInt8>,
        at offset: Kernel.File.Offset
    ) throws(Error) -> Int {
        try span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
            try pwrite(descriptor, from: buffer, at: offset)
        }
    }
}

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.IO.Write {
        /// Writes bytes to a file handle at the current file position.
        ///
        /// ## Threading
        /// This call blocks until at least one byte is written or an error occurs.
        /// The file position is advanced by the number of bytes written. Concurrent
        /// sequential writes require external synchronization.
        ///
        /// ## Partial Writes
        /// May return fewer bytes than `buffer.count`. This is not an error—loop until
        /// all data is written.
        ///
        /// - Parameters:
        ///   - descriptor: The file handle to write to.
        ///   - buffer: The buffer to write from.
        /// - Returns: Number of bytes written (may be less than `buffer.count`).
        /// - Throws: ``Kernel/IO/Write/Error`` on failure.
        @inlinable
        public static func write(
            _ descriptor: Kernel.Descriptor,
            from buffer: UnsafeRawBufferPointer
        ) throws(Error) -> Int {
            guard let baseAddress = buffer.baseAddress else {
                return 0
            }
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }

            var bytesWritten: DWORD = 0
            let result = WriteFile(
                descriptor.rawValue,
                baseAddress,
                DWORD(min(buffer.count, Int(DWORD.max))),
                &bytesWritten,
                nil
            )

            try Kernel.Syscall.require(result, .isTrue, orThrow: Error.current())
            return Int(bytesWritten)
        }

        /// Writes bytes to a file handle at a specific offset without changing the file position.
        ///
        /// ## Threading
        /// This call blocks until at least one byte is written or an error occurs.
        /// The file position is **not** modified. Uses OVERLAPPED for positional I/O.
        ///
        /// - Parameters:
        ///   - descriptor: The file handle to write to.
        ///   - buffer: The buffer to write from.
        ///   - offset: The file offset to write at.
        /// - Returns: Number of bytes written (may be less than `buffer.count`).
        /// - Throws: ``Kernel/IO/Write/Error`` on failure.
        @inlinable
        public static func pwrite(
            _ descriptor: Kernel.Descriptor,
            from buffer: UnsafeRawBufferPointer,
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

            var bytesWritten: DWORD = 0
            let result = WriteFile(
                descriptor.rawValue,
                baseAddress,
                DWORD(min(buffer.count, Int(DWORD.max))),
                &bytesWritten,
                &overlapped
            )

            try Kernel.Syscall.require(result, .isTrue, orThrow: Error.current())
            return Int(bytesWritten)
        }
    }

#endif
