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

#if canImport(Glibc) || canImport(Musl)

    #if canImport(Glibc)
        internal import Glibc
        internal import CLinuxShim
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Kernel.Event.Descriptor {
        /// Flags for event descriptor creation.
        public struct Flags: Sendable, Equatable, Hashable {
            public let rawValue: Int32

            @inlinable
            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }

            /// No flags.
            public static let none = Flags(rawValue: 0)

            /// Set close-on-exec flag.
            public static let cloexec = Flags(rawValue: Int32(EFD_CLOEXEC))

            /// Set non-blocking mode.
            public static let nonblock = Flags(rawValue: Int32(EFD_NONBLOCK))

            /// Provide semaphore-like semantics for reads.
            public static let semaphore = Flags(rawValue: Int32(EFD_SEMAPHORE))

            /// Combines multiple flags.
            @inlinable
            public static func | (lhs: Flags, rhs: Flags) -> Flags {
                Flags(rawValue: lhs.rawValue | rhs.rawValue)
            }
        }
    }

#endif
