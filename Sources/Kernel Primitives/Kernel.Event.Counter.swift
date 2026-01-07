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

#if canImport(Glibc) || canImport(Musl)

    extension Kernel.Event {
        /// Counter value for eventfd operations.
        ///
        /// Eventfd maintains an internal 64-bit counter. Reading returns
        /// the counter value and resets it; writing adds to the counter.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Create an eventfd with initial value 0
        /// let efd = try Kernel.Event.Descriptor.create(initval: .zero)
        ///
        /// // Signal the eventfd (add 1 to counter)
        /// try Kernel.Event.Descriptor.write(efd, value: .one)
        ///
        /// // Read the counter value
        /// let count = try Kernel.Event.Descriptor.read(efd)
        /// ```
        public struct Counter: RawRepresentable, Sendable, Equatable, Hashable, Comparable {
            public let rawValue: UInt64

            /// Creates a counter value.
            ///
            /// - Parameter rawValue: The 64-bit counter value.
            @inlinable
            public init(rawValue: UInt64) {
                self.rawValue = rawValue
            }

            /// Creates a counter value from an integer.
            ///
            /// - Parameter value: The counter value.
            @inlinable
            public init(_ value: UInt64) {
                self.rawValue = value
            }

            /// Creates a counter from a UInt32 initial value.
            ///
            /// Used for eventfd creation which accepts UInt32.
            ///
            /// - Parameter initval: The initial counter value.
            @inlinable
            public init(initval: UInt32) {
                self.rawValue = UInt64(initval)
            }

            // MARK: - Common Values

            /// Zero counter value.
            public static let zero = Counter(rawValue: 0)

            /// One - the common value for wakeup signals.
            public static let one = Counter(rawValue: 1)

            // MARK: - Comparable

            @inlinable
            public static func < (lhs: Counter, rhs: Counter) -> Bool {
                lhs.rawValue < rhs.rawValue
            }

            // MARK: - Queries

            /// Whether this counter is zero.
            @inlinable
            public var isZero: Bool {
                rawValue == 0
            }
        }
    }

    // MARK: - UInt32 from Counter

    extension UInt32 {
        /// Creates a UInt32 from an event counter for eventfd creation.
        ///
        /// Values larger than `UInt32.max` are clamped.
        ///
        /// - Parameter counter: The counter value.
        @inlinable
        public init(_ counter: Kernel.Event.Counter) {
            self = UInt32(clamping: counter.rawValue)
        }
    }

    // MARK: - ExpressibleByIntegerLiteral

    extension Kernel.Event.Counter: ExpressibleByIntegerLiteral {
        @inlinable
        public init(integerLiteral value: UInt64) {
            self.rawValue = value
        }
    }

    // MARK: - CustomStringConvertible

    extension Kernel.Event.Counter: CustomStringConvertible {
        public var description: String {
            "\(rawValue)"
        }
    }

#endif
