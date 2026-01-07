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

#if os(Windows)
    public import WinSDK
#endif

extension Kernel.Event {
    /// Event source identifier.
    ///
    /// Identifies the source of an event, which may be a file descriptor,
    /// timer ID, signal number, or other platform-specific identifier.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // From a descriptor
    /// let id = Event.ID(descriptor: fd)
    ///
    /// // From a raw identifier
    /// let id: Event.ID = 42
    /// ```
    ///
    /// ## Platform Notes
    ///
    /// - **epoll**: File descriptor (`int`)
    /// - **kqueue**: Identifier type depends on filter (fd, pid, signal, etc.)
    /// - **io_uring**: File descriptor for most operations
    public typealias ID = Tagged<Kernel.Event, UInt>
}

// MARK: - Event.ID Conversions

extension Tagged where Tag == Kernel.Event, RawValue == UInt {
    /// Creates an identifier from a file descriptor.
    @inlinable
    public init(descriptor: Kernel.Descriptor) {
        #if os(Windows)
            self.init(UInt(bitPattern: descriptor.rawValue))
        #else
            self.init(UInt(bitPattern: Int(descriptor.rawValue)))
        #endif
    }

    /// Creates an identifier from a socket descriptor.
    @inlinable
    public init(socket: Kernel.Socket.Descriptor) {
        #if os(Windows)
            self.init(UInt(socket.rawValue))
        #else
            self.init(UInt(bitPattern: Int(socket.rawValue)))
        #endif
    }

    /// Creates an identifier from an Int32 (for signals, etc.).
    @inlinable
    public init(_ value: Int32) {
        self.init(UInt(bitPattern: Int(value)))
    }
}

// MARK: - Descriptor from Event.ID

extension Kernel.Descriptor {
    /// Creates a file descriptor from an event identifier, if valid.
    ///
    /// - Parameter id: The event identifier.
    /// - Returns: `nil` if the value doesn't fit in the descriptor's raw type.
    @inlinable
    public init?(_ id: Kernel.Event.ID) {
        #if os(Windows)
            guard let handle = HANDLE(bitPattern: Int(id.rawValue)) else { return nil }
            self.init(rawValue: handle)
        #else
            guard id.rawValue <= UInt(Int32.max) else { return nil }
            self.init(rawValue: Int32(id.rawValue))
        #endif
    }
}
