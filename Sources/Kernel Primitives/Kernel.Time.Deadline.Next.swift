// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Synchronization

extension Kernel.Time.Deadline {
    /// Atomic deadline storage for cross-thread coordination.
    ///
    /// Stores an optional deadline as nanoseconds, where `UInt64.max` represents
    /// "no deadline". Uses acquiring/releasing memory ordering for thread safety.
    ///
    /// ## Usage
    /// ```swift
    /// let next = Kernel.Time.Deadline.Next()
    ///
    /// // Producer (deadline scheduler)
    /// next.store(deadline.nanoseconds)
    ///
    /// // Consumer (poll thread)
    /// if let deadline = next.value {
    ///     // use deadline for timeout
    /// }
    /// ```
    ///
    /// ## Thread Safety
    /// Sendable via internal `Atomic<UInt64>` synchronization.
    public final class Next: Sendable {
        let _value: Atomic<UInt64>

        /// Creates a new deadline storage (initially no deadline).
        public init() {
            self._value = Atomic(UInt64.max)
        }

        /// The current deadline in nanoseconds, or `.max` for no deadline.
        public var nanoseconds: UInt64 {
            _value.load(ordering: .acquiring)
        }

        /// Updates the deadline.
        ///
        /// - Parameter nanoseconds: The new deadline in nanoseconds,
        ///   or `UInt64.max` for no deadline.
        public func store(_ nanoseconds: UInt64) {
            _value.store(nanoseconds, ordering: .releasing)
        }

        /// The deadline as an optional `Deadline`.
        ///
        /// Returns `nil` if no deadline is set (nanoseconds == .max).
        public var value: Kernel.Time.Deadline? {
            let ns = nanoseconds
            guard ns != .max else { return nil }
            return Kernel.Time.Deadline(nanoseconds: ns)
        }
    }
}
