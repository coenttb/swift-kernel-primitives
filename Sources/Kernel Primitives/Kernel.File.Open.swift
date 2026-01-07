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
    /// Types and options for opening files.
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
        @inlinable
        public static func open(
            path: borrowing Kernel.Path,
            mode: Kernel.File.Open.Mode,
            options: Kernel.File.Open.Options,
            permissions: Kernel.File.Permissions
        ) throws(Kernel.File.Open.Error) -> Kernel.Descriptor {
            try open(unsafePath: path.unsafeCString, mode: mode, options: options, permissions: permissions)
        }

        /// Opens a file at the specified path.
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
        @inlinable
        public static func open(
            path: borrowing Kernel.Path,
            mode: Kernel.File.Open.Mode,
            options: Kernel.File.Open.Options,
            permissions: Kernel.File.Permissions
        ) throws(Kernel.File.Open.Error) -> Kernel.Descriptor {
            try open(unsafePath: path.unsafeCString, mode: mode, options: options, permissions: permissions)
        }

        /// Opens a file at the specified path (Windows wide string).
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
