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
    /// Memory protection flags controlling access to mapped pages.
    ///
    /// Specifies what operations are permitted on a memory mapping. The kernel
    /// enforces these protections at the hardware level using page table entries.
    /// Violating protection (e.g., writing to read-only memory) triggers a signal
    /// (`SIGSEGV` on POSIX, access violation on Windows).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Map a file read-only
    /// let ptr = try Kernel.Memory.Map.map(
    ///     fd: fd,
    ///     length: size,
    ///     protection: .read,
    ///     flags: .private
    /// )
    /// defer { try? Kernel.Memory.Map.unmap(ptr, length: size) }
    ///
    /// // Map with read-write access
    /// let rwPtr = try Kernel.Memory.Map.map(
    ///     fd: fd,
    ///     length: size,
    ///     protection: .read | .write,
    ///     flags: .shared
    /// )
    ///
    /// // Executable mapping (JIT, etc.)
    /// let execPtr = try Kernel.Memory.Map.map(
    ///     fd: fd,
    ///     length: size,
    ///     protection: .read | .execute,
    ///     flags: .private
    /// )
    /// ```
    ///
    /// ## Platform Behavior
    ///
    /// | Protection | POSIX | Windows |
    /// |------------|-------|---------|
    /// | `.read` | `PROT_READ` | `PAGE_READONLY` |
    /// | `.write` | `PROT_WRITE` | `PAGE_READWRITE` |
    /// | `.execute` | `PROT_EXEC` | `PAGE_EXECUTE*` |
    /// | `.none` | `PROT_NONE` | `PAGE_NOACCESS` |
    ///
    /// - Note: On some platforms, `.write` implies `.read`. On Windows,
    ///   specific combinations map to discrete protection constants.
    ///
    /// ## See Also
    ///
    /// - ``Kernel/Memory/Map/Flags``
    /// - ``Kernel/Memory/Map/map(fd:length:protection:flags:offset:)``
    public struct Protection: Sendable, Equatable, Hashable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// No access permitted.
        ///
        /// Any access to pages with this protection will fault. Useful for guard
        /// pages or reserving address space without committing memory.
        ///
        /// - POSIX: `PROT_NONE`
        /// - Windows: `PAGE_NOACCESS`
        public static let none = Protection(rawValue: 0)

        /// Combines multiple protection flags.
        @inlinable
        public static func | (lhs: Protection, rhs: Protection) -> Protection {
            Protection(rawValue: lhs.rawValue | rhs.rawValue)
        }

        /// Checks if this contains another protection flag.
        @inlinable
        public func contains(_ other: Protection) -> Bool {
            (rawValue & other.rawValue) == other.rawValue
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

    extension Kernel.Memory.Map.Protection {
        /// Permits reading from mapped pages.
        ///
        /// Data can be loaded from the mapping. Required for most use cases.
        /// Combine with `.write` for mutable access or `.execute` for code.
        ///
        /// - POSIX: `PROT_READ`
        public static let read = Self(rawValue: PROT_READ)

        /// Permits writing to mapped pages.
        ///
        /// Data can be stored to the mapping. For file mappings with `.shared`,
        /// writes are visible to other processes and may be written back to disk.
        /// For `.private` mappings, a copy-on-write copy is made.
        ///
        /// - POSIX: `PROT_WRITE`
        public static let write = Self(rawValue: PROT_WRITE)

        /// Permits executing code from mapped pages.
        ///
        /// CPU can execute instructions from the mapping. Required for JIT
        /// compilation, dynamic code generation, and loading executable code.
        ///
        /// - Warning: Some platforms require W^X (write XOR execute) policy:
        ///   pages cannot be both writable and executable simultaneously.
        ///   Typical pattern: map writable, write code, change to executable.
        ///
        /// - POSIX: `PROT_EXEC`
        public static let execute = Self(rawValue: PROT_EXEC)

        /// Convenience for read and write access.
        ///
        /// Equivalent to `.read | .write`. Most common for mutable data mappings.
        public static let readWrite = read | write
    }

#endif

// MARK: - Windows Constants

#if os(Windows)
    public import WinSDK

    extension Kernel.Memory.Map.Protection {
        /// Permits reading from mapped pages.
        ///
        /// - Windows: Contributes to `PAGE_READONLY` or `PAGE_READWRITE`
        public static let read = Self(rawValue: 1)

        /// Permits writing to mapped pages.
        ///
        /// - Windows: Contributes to `PAGE_READWRITE`
        public static let write = Self(rawValue: 2)

        /// Permits executing code from mapped pages.
        ///
        /// - Windows: Contributes to `PAGE_EXECUTE*` variants
        public static let execute = Self(rawValue: 4)

        /// Convenience for read and write access.
        public static let readWrite = read | write

        /// Converts to Windows page protection constant.
        var windowsPageProtection: DWORD {
            let r = contains(.read)
            let w = contains(.write)
            let x = contains(.execute)

            switch (r, w, x) {
            case (false, false, false): return DWORD(PAGE_NOACCESS)
            case (true, false, false): return DWORD(PAGE_READONLY)
            case (true, true, false): return DWORD(PAGE_READWRITE)
            case (true, false, true): return DWORD(PAGE_EXECUTE_READ)
            case (true, true, true): return DWORD(PAGE_EXECUTE_READWRITE)
            case (false, false, true): return DWORD(PAGE_EXECUTE)
            case (false, true, false): return DWORD(PAGE_READWRITE)
            case (false, true, true): return DWORD(PAGE_EXECUTE_READWRITE)
            }
        }

        /// Converts to Windows file map access flags.
        var windowsFileMapAccess: DWORD {
            var access: DWORD = 0
            if contains(.read) { access |= DWORD(FILE_MAP_READ) }
            if contains(.write) { access |= DWORD(FILE_MAP_WRITE) }
            if contains(.execute) { access |= DWORD(FILE_MAP_EXECUTE) }
            return access
        }
    }

#endif
