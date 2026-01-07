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

extension Kernel.Memory.Map {
    /// Flags controlling memory mapping behavior.
    ///
    /// Determines how the mapping interacts with the underlying file (if any)
    /// and other processes. The key choice is between `.shared` (visible to
    /// others, written back to file) and `.private` (copy-on-write, isolated).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Private copy-on-write mapping (most common for reading files)
    /// let ptr = try Kernel.Memory.Map.map(
    ///     fd: fd,
    ///     length: size,
    ///     protection: .read,
    ///     flags: .private
    /// )
    /// defer { try? Kernel.Memory.Map.unmap(ptr, length: size) }
    ///
    /// // Shared mapping for IPC or writing back to file
    /// let sharedPtr = try Kernel.Memory.Map.map(
    ///     fd: fd,
    ///     length: size,
    ///     protection: .readWrite,
    ///     flags: .shared
    /// )
    ///
    /// // Anonymous mapping (not backed by file)
    /// let anonPtr = try Kernel.Memory.Map.map(
    ///     fd: Kernel.Descriptor.invalid,
    ///     length: pageSize,
    ///     protection: .readWrite,
    ///     flags: .private | .anonymous
    /// )
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``Kernel/Memory/Map/Protection``
    /// - ``Kernel/Memory/Map/map(fd:length:protection:flags:offset:)``
    public struct Flags: Sendable, Equatable, Hashable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Combines multiple flags.
        @inlinable
        public static func | (lhs: Flags, rhs: Flags) -> Flags {
            Flags(rawValue: lhs.rawValue | rhs.rawValue)
        }
    }
}

// MARK: - POSIX Constants

#if !os(Windows)

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        public import Glibc
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Memory.Map.Flags {
        /// Shares modifications with other processes mapping the same file.
        ///
        /// Writes are visible to all processes with shared mappings of the file.
        /// Changes are written back to the underlying file (potentially lazily).
        /// Use for inter-process communication or persistent file updates.
        ///
        /// - POSIX: `MAP_SHARED`
        public static let shared = Self(rawValue: MAP_SHARED)

        /// Creates a private copy-on-write mapping.
        ///
        /// The mapping starts as a view of the file, but writes create private
        /// copies of the affected pages. Other processes don't see changes, and
        /// changes aren't written to the file. Most common for read-only access.
        ///
        /// - POSIX: `MAP_PRIVATE`
        public static let `private` = Self(rawValue: MAP_PRIVATE)

        /// Creates a mapping not backed by any file.
        ///
        /// Memory is initialized to zero. The `fd` parameter is ignored (pass
        /// `Kernel.Descriptor.invalid`). Useful for allocating large memory
        /// regions or creating shared memory without a file.
        ///
        /// - POSIX: `MAP_ANON` / `MAP_ANONYMOUS`
        public static let anonymous = Self(rawValue: MAP_ANON)

        /// Places mapping at exactly the specified address.
        ///
        /// The address hint becomes a requirement. If the region overlaps existing
        /// mappings, they are unmapped. Use with extreme caution - incorrect use
        /// can corrupt process memory.
        ///
        /// - POSIX: `MAP_FIXED`
        /// - Warning: This is dangerous and rarely needed. Prefer letting the
        ///   kernel choose the address.
        public static let fixed = Self(rawValue: MAP_FIXED)
    }

#endif

// MARK: - Windows Constants

#if os(Windows)

    extension Kernel.Memory.Map.Flags {
        /// Shares modifications with other processes.
        ///
        /// - Windows: Uses shared file mapping semantics
        public static let shared = Self(rawValue: 1)

        /// Creates a private copy-on-write mapping.
        ///
        /// - Windows: Uses `FILE_MAP_COPY` semantics
        public static let `private` = Self(rawValue: 2)

        /// Creates a mapping not backed by any file.
        ///
        /// - Windows: Uses page file backing
        public static let anonymous = Self(rawValue: 4)

        /// Places mapping at exactly the specified address.
        ///
        /// - Warning: Dangerous. Prefer letting the system choose the address.
        public static let fixed = Self(rawValue: 8)
    }

#endif
