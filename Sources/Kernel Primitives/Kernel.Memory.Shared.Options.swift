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

extension Kernel.Memory.Shared {
/// Creation options for shared memory objects.
///
/// Controls whether the object is created, whether creation fails
/// if it already exists, or whether an existing object is truncated.
public struct Options: OptionSet, Sendable, Equatable, Hashable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// Create the shared memory object if it doesn't exist.
    public static let create = Self(rawValue: 1 << 0)

    /// Fail if the object already exists (requires `.create`).
    public static let exclusive = Self(rawValue: 1 << 1)

    /// Truncate the object to zero length if it exists (requires `.create`).
    ///
    /// - Note: On Windows, this option is ignored. Use `ftruncate`
    ///   or resize the mapping after creation.
    public static let truncate = Self(rawValue: 1 << 2)
}
}

// MARK: - POSIX Conversion

#if !os(Windows)

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        public import Glibc
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Memory.Shared.Options {
        /// Converts the options to POSIX open flags.
        @usableFromInline
        internal var posixFlags: Int32 {
            var flags: Int32 = 0
            if contains(.create) { flags |= O_CREAT }
            if contains(.exclusive) { flags |= O_EXCL }
            if contains(.truncate) { flags |= O_TRUNC }
            return flags
        }
    }

#endif

