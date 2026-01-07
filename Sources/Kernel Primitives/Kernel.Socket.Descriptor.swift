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

extension Kernel.Socket {
    /// Socket descriptor (POSIX file descriptor or Windows SOCKET).
    ///
    /// On POSIX systems, sockets use the same `Int32` file descriptor type as regular files,
    /// so this type is interchangeable with `Kernel.Descriptor`.
    ///
    /// On Windows, sockets use a distinct `SOCKET` type (`UInt64`), which is separate from
    /// `HANDLE` used for file I/O. This type provides the correct underlying representation
    /// for WinSock APIs.
    ///
    /// ## Thread Safety
    ///
    /// `Kernel.Socket.Descriptor` is `Sendable` (it's just an integer value).
    /// However, **sharing a socket across threads requires external synchronization**:
    ///
    /// - **Concurrent reads/writes** require synchronization unless using thread-safe patterns.
    /// - **Close** invalidates the descriptor for all threads.
    ///
    /// The descriptor value itself can be safely passed between threads; it's the
    /// underlying kernel resource that requires coordination.
    public struct Descriptor: RawRepresentable, Equatable, Hashable, Sendable {
        #if os(Windows)
            /// Windows SOCKET is a UInt64 (UINT_PTR).
            public typealias RawValue = UInt64
        #else
            /// POSIX socket descriptor (same as file descriptor).
            public typealias RawValue = Int32
        #endif

        public let rawValue: RawValue

        @inlinable
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        /// Invalid socket sentinel.
        ///
        /// - POSIX: `-1`
        /// - Windows: `INVALID_SOCKET` (`UInt64.max`)
        public static var invalid: Descriptor {
            #if os(Windows)
                Descriptor(rawValue: UInt64.max)  // INVALID_SOCKET
            #else
                Descriptor(rawValue: -1)
            #endif
        }

        /// Checks if this socket descriptor is valid (not the invalid sentinel).
        @inlinable
        public var isValid: Bool {
            #if os(Windows)
                rawValue != UInt64.max
            #else
                rawValue >= 0
            #endif
        }
    }
}

// MARK: - Kernel.Descriptor Interop (POSIX only)

#if !os(Windows)

    extension Kernel.Socket.Descriptor {
        /// Creates a socket descriptor from a file descriptor.
        ///
        /// On POSIX, socket FDs and file FDs are interchangeable (both `Int32`).
        @inlinable
        public init(_ descriptor: Kernel.Descriptor) {
            self.init(rawValue: descriptor.rawValue)
        }

    }

    // MARK: - Kernel.Descriptor from Socket.Descriptor

    extension Kernel.Descriptor {
        /// Creates a file descriptor from a socket descriptor.
        ///
        /// On POSIX, socket FDs and file FDs are interchangeable (both `Int32`).
        @inlinable
        public init(_ socket: Kernel.Socket.Descriptor) {
            self.init(rawValue: socket.rawValue)
        }
    }

#endif
