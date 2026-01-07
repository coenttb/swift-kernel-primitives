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

extension Kernel.Time {
    /// A point in monotonic time for deadline-based scheduling.
    ///
    /// Deadline represents an absolute point in monotonic time, suitable for
    /// timeout calculations and event scheduling. Uses monotonic clock which
    /// is not affected by system time changes.
    ///
    /// ## API
    /// - Creation: `now`, `after(nanoseconds:)`, `after(milliseconds:)`
    /// - Special value: `never` (infinite timeout)
    /// - Comparison: `Comparable` conformance
    /// - Queries: `hasExpired`, `remainingNanoseconds`, `remaining`
    ///
    /// ## Usage
    /// ```swift
    /// // Create deadline 100ms from now
    /// let deadline = Kernel.Time.Deadline.after(milliseconds: 100)
    ///
    /// // Check if deadline has passed
    /// if Kernel.Time.Deadline.now >= deadline {
    ///     // Deadline expired
    /// }
    ///
    /// // Infinite timeout
    /// let noTimeout = Kernel.Time.Deadline.never
    /// ```
    public struct Deadline: Sendable, Hashable {
        /// Absolute time in nanoseconds from monotonic clock.
        public let nanoseconds: UInt64

        /// Creates a deadline from an absolute nanosecond value.
        ///
        /// - Parameter nanoseconds: Absolute monotonic time in nanoseconds.
        @inlinable
        public init(nanoseconds: UInt64) {
            self.nanoseconds = nanoseconds
        }

        /// A deadline that never expires.
        ///
        /// Use this for operations that should wait indefinitely.
        @inlinable
        public static var never: Deadline {
            Deadline(nanoseconds: .max)
        }

        /// The current monotonic time as a deadline.
        ///
        /// Useful for comparisons and as a base for relative deadlines.
        @inlinable
        public static var now: Deadline {
            Deadline(nanoseconds: Kernel.Time.monotonicNanoseconds())
        }

        /// Creates a deadline at the specified duration from now.
        ///
        /// Uses saturating arithmetic to prevent overflow - very large
        /// values will clamp to `Deadline.never`.
        ///
        /// - Parameter nanoseconds: Duration in nanoseconds. Negative values
        ///   create a deadline in the past (already expired).
        /// - Returns: A deadline at `now + nanoseconds`.
        @inlinable
        public static func after(nanoseconds: Int64) -> Deadline {
            let current = Kernel.Time.monotonicNanoseconds()
            if nanoseconds <= 0 {
                // Past or immediate deadline
                let subtracted = current &- UInt64(-nanoseconds)
                return Deadline(nanoseconds: subtracted > current ? 0 : subtracted)
            } else {
                // Future deadline with saturation
                let added = current &+ UInt64(nanoseconds)
                return Deadline(nanoseconds: added < current ? .max : added)
            }
        }

        /// Creates a deadline at the specified milliseconds from now.
        ///
        /// Uses saturating arithmetic to prevent overflow.
        ///
        /// - Parameter milliseconds: Duration in milliseconds.
        /// - Returns: A deadline at `now + milliseconds`.
        @inlinable
        public static func after(milliseconds: Int64) -> Deadline {
            // Saturating multiplication: 1ms = 1,000,000 ns
            let nsPerMs: Int64 = 1_000_000
            let (result, overflow) = milliseconds.multipliedReportingOverflow(by: nsPerMs)
            if overflow {
                return milliseconds > 0 ? .never : Deadline(nanoseconds: 0)
            }
            return after(nanoseconds: result)
        }
    }
}

// MARK: - Comparable

extension Kernel.Time.Deadline: Comparable {
    @inlinable
    public static func < (lhs: Kernel.Time.Deadline, rhs: Kernel.Time.Deadline) -> Bool {
        lhs.nanoseconds < rhs.nanoseconds
    }
}

// MARK: - Queries

extension Kernel.Time.Deadline {
    /// Whether this deadline has expired.
    ///
    /// Compares against the current monotonic time.
    @inlinable
    public var hasExpired: Bool {
        Self.now >= self
    }

    /// Nanoseconds remaining until this deadline.
    ///
    /// Returns 0 if the deadline has already expired.
    @inlinable
    public var remainingNanoseconds: Int64 {
        let now = Self.now.nanoseconds
        return nanoseconds > now ? Int64(nanoseconds - now) : 0
    }

    /// Remaining time as a Duration.
    ///
    /// Returns `.zero` if the deadline has already expired.
    @inlinable
    public var remaining: Duration {
        .nanoseconds(remainingNanoseconds)
    }
}
