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

extension Kernel.File {
    /// File open operations and configuration types.
    ///
    /// Provides the fundamental `open()` syscall for creating or opening files.
    /// Returns a raw ``Kernel/Descriptor`` that must be closed explicitly via
    /// ``Kernel/Close/close(_:)``.
    ///
    /// ## See Also
    /// - ``Kernel/File/Open/Mode``
    /// - ``Kernel/File/Open/Options``
    /// - ``Kernel/File/Permissions``
    public struct Open {

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

    extension Kernel.File.Open {
        /// Opens a file at the specified path.
        ///
        /// ## Threading
        /// This call blocks until the open completes. The open syscall may block
        /// on networked filesystems or when opening FIFOs/device files.
        ///
        /// ## Descriptor Ownership
        /// The caller receives ownership of the returned descriptor and must close it
        /// explicitly via ``Kernel/Close/close(_:)``. Failing to close leaks the
        /// kernel resource until process termination.
        ///
        /// ## Errors
        /// - ``Error/notFound``: Path does not exist and `.create` not specified
        /// - ``Error/exists``: Path exists and `.exclusive` was specified
        /// - ``Error/permission``: Insufficient permissions for requested mode
        /// - ``Error/isDirectory``: Cannot open directory with write mode
        /// - ``Error/tooManyOpen``: Process or system descriptor limit reached
        ///
        /// - Parameters:
        ///   - path: The file path to open.
        ///   - mode: Read/write access mode.
        ///   - options: Creation and behavior options.
        ///   - permissions: POSIX permissions for newly created files.
        /// - Returns: A file descriptor for the opened file.
        /// - Throws: ``Kernel/File/Open/Error`` on failure.
        @inlinable
        public static func open(
            path: borrowing Kernel.Path,
            mode: Kernel.File.Open.Mode,
            options: Kernel.File.Open.Options,
            permissions: Kernel.File.Permissions
        ) throws(Kernel.File.Open.Error) -> Kernel.Descriptor {
            try open(unsafePath: path.unsafeCString, mode: mode, options: options, permissions: permissions)
        }

        /// Opens a file at the specified path using an unsafe C string pointer.
        ///
        /// This is the low-level variant for callers that already have a null-terminated
        /// path string. Prefer ``open(path:mode:options:permissions:)`` when possible.
        ///
        /// - Parameters:
        ///   - unsafePath: Null-terminated path string. Must remain valid for the call duration.
        ///   - mode: Read/write access mode.
        ///   - options: Creation and behavior options.
        ///   - permissions: POSIX permissions for newly created files.
        /// - Returns: A file descriptor for the opened file.
        /// - Throws: ``Kernel/File/Open/Error`` on failure.
        @inlinable
        public static func open(
            unsafePath: UnsafePointer<Kernel.Path.Char>,
            mode: Kernel.File.Open.Mode,
            options: Kernel.File.Open.Options,
            permissions: Kernel.File.Permissions
        ) throws(Kernel.File.Open.Error) -> Kernel.Descriptor {
            let flags = mode.posixFlags | options.posixFlags

            let fd: Int32
            #if canImport(Darwin)
                if options.contains(.create) {
                    fd = Darwin.open(unsafePath, flags, mode_t(permissions.rawValue))
                } else {
                    fd = Darwin.open(unsafePath, flags)
                }
            #elseif canImport(Glibc)
                if options.contains(.create) {
                    fd = Glibc.open(unsafePath, flags, mode_t(permissions.rawValue))
                } else {
                    fd = Glibc.open(unsafePath, flags)
                }
            #elseif canImport(Musl)
                if options.contains(.create) {
                    fd = Musl.open(unsafePath, flags, mode_t(permissions.rawValue))
                } else {
                    fd = Musl.open(unsafePath, flags)
                }
            #endif

            guard fd >= 0 else {
                throw .current()
            }

            #if canImport(Darwin)
                if options.contains(.cacheDisabled) {
                    _ = fcntl(fd, F_NOCACHE, 1)
                }
            #endif

            return Kernel.Descriptor(rawValue: fd)
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.File.Open {
        /// Opens a file at the specified path.
        ///
        /// ## Threading
        /// This call blocks until the open completes. CreateFileW may block
        /// on networked paths or when opening device files.
        ///
        /// ## Handle Ownership
        /// The caller receives ownership of the returned handle and must close it
        /// explicitly via ``Kernel/Close/close(_:)``. Failing to close leaks the
        /// kernel resource until process termination.
        ///
        /// ## Errors
        /// - ``Error/notFound``: Path does not exist and `.create` not specified
        /// - ``Error/exists``: Path exists and `.exclusive` was specified
        /// - ``Error/permission``: Access denied for requested mode
        /// - ``Error/isDirectory``: Cannot open directory with write mode
        /// - ``Error/tooManyOpen``: System handle limit reached
        ///
        /// - Parameters:
        ///   - path: The file path to open.
        ///   - mode: Read/write access mode.
        ///   - options: Creation and behavior options.
        ///   - permissions: Ignored on Windows (permissions are ACL-based).
        /// - Returns: A file handle for the opened file.
        /// - Throws: ``Kernel/File/Open/Error`` on failure.
        @inlinable
        public static func open(
            path: borrowing Kernel.Path,
            mode: Kernel.File.Open.Mode,
            options: Kernel.File.Open.Options,
            permissions: Kernel.File.Permissions
        ) throws(Kernel.File.Open.Error) -> Kernel.Descriptor {
            try open(unsafePath: path.unsafeCString, mode: mode, options: options, permissions: permissions)
        }

        /// Opens a file at the specified path using an unsafe wide string pointer.
        ///
        /// This is the low-level variant for callers that already have a null-terminated
        /// UTF-16 path string. Prefer ``open(path:mode:options:permissions:)`` when possible.
        ///
        /// - Parameters:
        ///   - unsafePath: Null-terminated UTF-16 path string. Must remain valid for the call duration.
        ///   - mode: Read/write access mode.
        ///   - options: Creation and behavior options.
        ///   - permissions: Ignored on Windows (permissions are ACL-based).
        /// - Returns: A file handle for the opened file.
        /// - Throws: ``Kernel/File/Open/Error`` on failure.
        @inlinable
        public static func open(
            unsafePath: UnsafePointer<Kernel.Path.Char>,
            mode: Kernel.File.Open.Mode,
            options: Kernel.File.Open.Options,
            permissions: Kernel.File.Permissions
        ) throws(Kernel.File.Open.Error) -> Kernel.Descriptor {
            let desiredAccess = mode.windowsDesiredAccess(options: options)
            let creationDisposition = options.windowsCreationDisposition
            let flagsAndAttributes = options.windowsFlagsAndAttributes
            let shareMode = Kernel.File.Open.Options.windowsShareMode

            var securityAttributes = SECURITY_ATTRIBUTES()
            securityAttributes.nLength = DWORD(MemoryLayout<SECURITY_ATTRIBUTES>.size)
            securityAttributes.lpSecurityDescriptor = nil
            securityAttributes.bInheritHandle = options.contains(.execClose) ? false : true

            let handle = CreateFileW(
                unsafePath,
                desiredAccess,
                shareMode,
                &securityAttributes,
                creationDisposition,
                flagsAndAttributes,
                nil
            )

            guard let handle = handle, handle != INVALID_HANDLE_VALUE else {
                throw .current()
            }

            return Kernel.Descriptor(rawValue: handle)
        }
    }

#endif
