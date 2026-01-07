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

// MARK: - Unlink Type

extension Kernel {
    /// File removal (unlink) operations.
    ///
    /// Removes directory entries (file names) from the filesystem. On POSIX,
    /// the underlying data is freed when the last link is removed and no
    /// processes have the file open. On Windows, deletion may be delayed
    /// until all handles are closed.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Remove a file
    /// try Kernel.Path.scope("/tmp/tempfile.txt") { path in
    ///     try Kernel.Unlink.unlink(path)
    /// }
    ///
    /// // Remove and ignore "file not found"
    /// do {
    ///     try Kernel.Unlink.unlink(path)
    /// } catch .notFound {
    ///     // Already deleted, that's fine
    /// }
    /// ```
    ///
    /// ## Platform Behavior
    ///
    /// | Platform | Syscall | Notes |
    /// |----------|---------|-------|
    /// | POSIX | `unlink()` | Removes link; data freed when refcount = 0 |
    /// | Windows | `DeleteFileW()` | DELETE_ON_CLOSE semantics |
    ///
    /// - Note: To remove directories, use a separate directory removal
    ///   function (not provided by Kernel).
    ///
    /// ## See Also
    ///
    /// - ``Kernel/Close``
    public enum Unlink: Sendable {

    }
}

// MARK: - POSIX Implementation

#if !os(Windows)

    #if canImport(Darwin)
        public import Darwin
    #elseif canImport(Glibc)
        public import Glibc
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Unlink {
        /// Removes a file or symbolic link.
        ///
        /// - Parameter path: The path to the file to remove.
        /// - Throws: `Kernel.Unlink.Error` on failure.
        @inlinable
        public static func unlink(_ path: borrowing Kernel.Path) throws(Error) {
            try unlink(path.unsafeCString)
        }

        /// Removes a file or symbolic link.
        ///
        /// - Parameter path: The path to the file to remove as a C string.
        /// - Throws: `Kernel.Unlink.Error` on failure.
        @inlinable
        public static func unlink(_ path: UnsafePointer<Kernel.Path.Char>) throws(Error) {
            #if canImport(Darwin)
                try Kernel.Syscall.require(Darwin.unlink(path), .equals(0), orThrow: Error.current())
            #elseif canImport(Glibc)
                try Kernel.Syscall.require(Glibc.unlink(path), .equals(0), orThrow: Error.current())
            #elseif canImport(Musl)
                try Kernel.Syscall.require(Musl.unlink(path), .equals(0), orThrow: Error.current())
            #endif
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.Unlink {
        /// Removes a file.
        ///
        /// - Parameter path: The path to the file to remove.
        /// - Throws: `Kernel.Unlink.Error` on failure.
        @inlinable
        public static func unlink(_ path: borrowing Kernel.Path) throws(Error) {
            try unlink(path.unsafeCString)
        }

        /// Removes a file.
        ///
        /// - Parameter path: The path to the file to remove as a wide string.
        /// - Throws: `Kernel.Unlink.Error` on failure.
        @inlinable
        public static func unlink(_ path: UnsafePointer<Kernel.Path.Char>) throws(Error) {
            let result = DeleteFileW(path)
            try Kernel.Syscall.require(result, .isTrue, orThrow: Error.current())
        }
    }

#endif
