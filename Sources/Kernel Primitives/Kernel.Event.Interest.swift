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

extension Kernel.Event {
    /// Requested readiness interests for event-driven I/O operations.
    ///
    /// Interests represent what readiness conditions the caller wants to be
    /// notified about. Multiple interests can be combined using set operations.
    /// This is a cross-platform abstraction over platform-specific event flags.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Monitor for both read and write readiness
    /// let interest: Interest = [.read, .write]
    ///
    /// // Check if interest includes read
    /// if interest.contains(.read) {
    ///     // Will be notified when data is available
    /// }
    /// ```
    ///
    /// ## Platform Mapping
    ///
    /// | Interest | kqueue | epoll | IOCP |
    /// |----------|--------|-------|------|
    /// | `.read` | `EVFILT_READ` | `EPOLLIN` | Read operation |
    /// | `.write` | `EVFILT_WRITE` | `EPOLLOUT` | Write operation |
    /// | `.priority` | N/A | `EPOLLPRI` | N/A |
    ///
    /// ## See Also
    ///
    /// - ``Kernel/Kqueue`` (Darwin)
    /// - ``Kernel/Event/Poll`` (Linux epoll)
    /// - ``Kernel/IOCP`` (Windows)
    public struct Interest: OptionSet, Sendable, Hashable {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Interest in read readiness (data available to read).
        public static let read = Interest(rawValue: 1 << 0)

        /// Interest in write readiness (buffer space available for writing).
        public static let write = Interest(rawValue: 1 << 1)

        /// Interest in priority/out-of-band data (platform-specific).
        ///
        /// On Linux, this maps to `EPOLLPRI` (urgent data).
        /// On Darwin, this is less commonly used.
        /// On Windows, this may not be directly supported.
        public static let priority = Interest(rawValue: 1 << 2)
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Event.Interest: CustomStringConvertible {
    public var description: String {
        var parts: [String] = []
        if contains(.read) { parts.append("read") }
        if contains(.write) { parts.append("write") }
        if contains(.priority) { parts.append("priority") }
        return parts.isEmpty ? "none" : parts.joined(separator: "|")
    }
}
