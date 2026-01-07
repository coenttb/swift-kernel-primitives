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

extension Kernel {
    /// A readiness event from the kernel selector.
    ///
    /// Events are produced by the selector's poll operation and represent
    /// what readiness conditions are now true for a registered descriptor.
    ///
    /// ## Architecture
    ///
    /// The event-driven I/O system is layered:
    /// 1. **Primitives**: `Event`, `Interest`, `Flags`, `ID`
    /// 2. **Platform backends**: kqueue (Darwin), epoll (Linux), IOCP (Windows)
    /// 3. **IO layer**: Selector, channels, async coordination
    ///
    /// ## Thread Safety
    ///
    /// Events are Sendable and can cross thread boundaries safely.
    ///
    /// ## Usage
    /// ```swift
    /// if event.interest.contains(.read) {
    ///     // Safe to read without blocking
    /// }
    /// if event.flags.contains(.hangup) {
    ///     // Peer closed connection
    /// }
    /// ```
    public struct Event: Sendable, Equatable {
        /// The registration ID this event belongs to.
        public let id: ID

        /// Which interests are now ready.
        ///
        /// May contain multiple bits if both read and write are ready.
        public let interest: Interest

        /// Additional status flags (error, hangup, etc.).
        public let flags: Flags

        /// Creates an event with the specified components.
        public init(id: ID, interest: Interest, flags: Flags = []) {
            self.id = id
            self.interest = interest
            self.flags = flags
        }

        /// An empty event for buffer initialization.
        public static let empty = Event(id: .zero, interest: [], flags: [])
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Event: CustomStringConvertible {
    public var description: String {
        var parts = ["Event(id: \(id), interest: \(interest)"]
        if !flags.isEmpty {
            parts.append(", flags: \(flags)")
        }
        return parts.joined() + ")"
    }
}
