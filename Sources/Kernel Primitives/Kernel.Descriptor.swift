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

#if os(Windows)
    public import WinSDK
#endif

extension Kernel {
    /// File descriptor (POSIX) or HANDLE (Windows).
    ///
    /// A type-safe wrapper around the platform's raw descriptor value.
    /// Higher layers (swift-io, swift-file-system) wrap this in `~Copyable` types
    /// to enforce ownership and prevent double-close.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Open a file and get a descriptor
    /// let fd = try Kernel.File.Open.open(
    ///     path: "/tmp/data.txt",
    ///     mode: [.read],
    ///     options: []
    /// )
    /// defer { try? Kernel.Close.close(fd) }
    ///
    /// // Read from the descriptor
    /// var buffer = [UInt8](repeating: 0, count: 4096)
    /// let bytesRead = try buffer.withUnsafeMutableBytes { buf in
    ///     try Kernel.IO.Read.read(fd, into: buf)
    /// }
    /// ```
    ///
    /// ## Thread Safety
    ///
    /// `Kernel.Descriptor` is `Sendable` (it's just an integer or pointer value).
    /// However, **sharing a descriptor across threads requires external synchronization**:
    ///
    /// - **Concurrent reads** on the same descriptor are safe if using positional I/O
    ///   (`pread`/`pwrite`). Sequential I/O (`read`/`write`) shares a file offset and
    ///   requires synchronization.
    /// - **Concurrent writes** always require synchronization unless using positional I/O.
    /// - **Close** invalidates the descriptor for all threads. Ensure no other thread
    ///   is using the descriptor before closing.
    ///
    /// The descriptor value itself can be safely passed between threads; it's the
    /// underlying kernel resource that requires coordination.
    ///
    /// ## See Also
    ///
    /// - ``Kernel/File/Open/open(path:mode:options:permissions:)``
    /// - ``Kernel/Close/close(_:)``
    /// - ``Kernel/File/Handle``
    public struct Descriptor: RawRepresentable, Equatable, Hashable {
        #if os(Windows)
            public typealias RawValue = HANDLE
        #else
            public typealias RawValue = Int32
        #endif

        public let rawValue: RawValue

        @inlinable
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        /// Invalid descriptor sentinel.
        ///
        /// - POSIX: `-1`
        /// - Windows: `INVALID_HANDLE_VALUE`
        public static var invalid: Descriptor {
            #if os(Windows)
                Descriptor(rawValue: INVALID_HANDLE_VALUE)
            #else
                Descriptor(rawValue: -1)
            #endif
        }

        /// Checks if this descriptor is valid (not the invalid sentinel).
        @inlinable
        public var isValid: Bool {
            #if os(Windows)
                rawValue != INVALID_HANDLE_VALUE
            #else
                rawValue >= 0
            #endif
        }
    }
}

// MARK: - Sendable

#if os(Windows)
    // On Windows, HANDLE is UnsafeMutableRawPointer which isn't Sendable.
    // However, this is safe because the handle is an opaque kernel identifier
    // that we never dereference - we only pass it to syscalls.
    // The value is immutable once created.
    extension Kernel.Descriptor: @unchecked Sendable {}
#else
    extension Kernel.Descriptor: Sendable {}
#endif
