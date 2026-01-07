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

extension Kernel.File {
    /// A move-only file handle with Direct I/O support.
    ///
    /// `Kernel.File.Handle` owns a file descriptor and stores the resolved
    /// Direct I/O mode and alignment requirements. These are fixed at
    /// open time and cannot be changed.
    ///
    /// ## Direct I/O Invariants
    ///
    /// When `direct == .direct`:
    /// - All read/write operations validate alignment
    /// - Buffer addresses must be aligned to `requirements.bufferAlignment`
    /// - File offsets must be aligned to `requirements.offsetAlignment`
    /// - Transfer lengths must be multiples of `requirements.lengthMultiple`
    ///
    /// When `direct == .uncached` (macOS) or `direct == .buffered`:
    /// - No alignment validation is performed
    /// - Operations use normal page cache semantics
    ///
    /// ## Lifecycle
    ///
    /// The handle closes the descriptor on deinit. For explicit control,
    /// use the `close()` consuming function.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Open with Direct I/O
    /// var options = Kernel.File.Open.Options()
    /// options.access = .readWrite
    /// options.cache = .direct
    /// let handle = try Kernel.File.open(path, options: options)
    ///
    /// // Allocate aligned buffer
    /// var buffer = try Buffer.Aligned(byteCount: 4096, alignment: 4096)
    ///
    /// // Read with automatic alignment validation
    /// let bytesRead = try handle.read(into: &buffer, at: 0)
    /// ```
    public struct Handle: ~Copyable, @unchecked Sendable {
        /// The underlying file descriptor.
        @usableFromInline
        let descriptor: Kernel.File.Descriptor

        /// The resolved Direct I/O mode (fixed at open time).
        public let direct: Kernel.File.Direct.Mode.Resolved

        /// The alignment requirements (fixed at open time).
        ///
        /// For `.direct` mode, this is always `.known(...)`.
        /// For `.uncached` or `.buffered`, this may be `.unknown(...)`.
        public let requirements: Kernel.File.Direct.Requirements

        /// Tracks whether close() has been called successfully.
        private var isClosed: Bool = false

        /// Creates a handle from a descriptor with Direct I/O state.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor (ownership transferred).
        ///   - direct: The resolved Direct I/O mode.
        ///   - requirements: The alignment requirements.
        public init(
            descriptor: Kernel.File.Descriptor,
            direct: Kernel.File.Direct.Mode.Resolved,
            requirements: Kernel.File.Direct.Requirements
        ) {
            self.descriptor = descriptor
            self.direct = direct
            self.requirements = requirements
        }

        deinit {
            guard !isClosed else { return }
            _ = Result { try Kernel.Close.close(descriptor) }
        }
    }
}

// MARK: - Read

extension Kernel.File.Handle {
    /// Reads from the file at a specific offset.
    ///
    /// For Direct I/O handles, this validates alignment before the syscall.
    ///
    /// - Parameters:
    ///   - buffer: The buffer to read into.
    ///   - offset: The file offset to read from.
    /// - Returns: The number of bytes read.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    public func read(
        into buffer: UnsafeMutableRawBufferPointer,
        at offset: Kernel.File.Offset
    ) throws(Kernel.IO.Read.Error) -> Int {
        try Kernel.IO.Read.pread(descriptor, into: buffer, at: offset)
    }

}

// MARK: - Write

extension Kernel.File.Handle {
    /// Writes to the file at a specific offset.
    ///
    /// - Parameters:
    ///   - buffer: The buffer to write from.
    ///   - offset: The file offset to write at.
    /// - Returns: The number of bytes written.
    /// - Throws: `Kernel.IO.Write.Error` on failure.
    public func write(
        from buffer: UnsafeRawBufferPointer,
        at offset: Kernel.File.Offset
    ) throws(Kernel.IO.Write.Error) -> Int {
        try Kernel.IO.Write.pwrite(descriptor, from: buffer, at: offset)
    }

}

// MARK: - Alignment Validation

extension Kernel.File.Handle {
    /// Validates alignment requirements for Direct I/O.
    ///
    /// - Parameters:
    ///   - buffer: The buffer address.
    ///   - offset: The file offset.
    ///   - length: The transfer length.
    /// - Throws: `Kernel.File.Handle.Error` on alignment violation.
    private func validateAlignment(
        buffer: Kernel.Memory.Address,
        offset: Kernel.File.Offset,
        length: Kernel.File.Size
    ) throws(Kernel.File.Handle.Error) {
        guard case .known(let alignment) = requirements else {
            throw .requirementsUnknown
        }

        if let directError = alignment.validate(buffer: buffer, offset: offset, length: length) {
            throw Error(from: directError)
        }
    }
}

// MARK: - Close

extension Kernel.File.Handle {
    /// Closes the file handle explicitly.
    ///
    /// On success, the handle is marked closed and subsequent calls are no-ops.
    /// On failure, the handle remains valid for retry - the token is preserved.
    ///
    /// - Throws: `Kernel.Close.Error` if the close syscall fails.
    public mutating func close() throws(Kernel.Close.Error) {
        guard !isClosed else { return }
        try Kernel.Close.close(descriptor)
        isClosed = true
    }
}

// MARK: - Descriptor Access

extension Kernel.File.Handle {
    /// Provides scoped access to the raw descriptor.
    ///
    /// Use this only when you need to pass the descriptor to other APIs.
    /// Do not close the descriptor within the closure.
    ///
    /// - Parameter body: A closure that receives the descriptor.
    /// - Returns: The value returned by `body`.
    /// - Throws: Any error thrown by `body`.
    public func withDescriptor<T, E: Swift.Error>(
        _ body: (Kernel.File.Descriptor) throws(E) -> T
    ) throws(E) -> T {
        try body(descriptor)
    }
}
