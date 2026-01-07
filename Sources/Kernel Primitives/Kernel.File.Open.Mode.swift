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

extension Kernel.File.Open {
    /// File access mode specifying read and/or write permissions.
    ///
    /// Controls how the opened file can be accessed. At least one mode must be specified
    /// for most operations. The file must have appropriate permissions for the requested mode.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Read-only access
    /// let fd = try Kernel.File.Open.open(path: path, mode: [.read], options: [])
    /// defer { try? Kernel.Close.close(fd) }
    ///
    /// // Write-only access (for logging, etc.)
    /// let logFd = try Kernel.File.Open.open(
    ///     path: "/var/log/app.log",
    ///     mode: [.write],
    ///     options: [.create, .append]
    /// )
    ///
    /// // Read-write access
    /// let dbFd = try Kernel.File.Open.open(
    ///     path: "data.db",
    ///     mode: [.read, .write],
    ///     options: [.create]
    /// )
    /// ```
    ///
    /// ## Platform Behavior
    ///
    /// | Mode | POSIX | Windows |
    /// |------|-------|---------|
    /// | `[.read]` | `O_RDONLY` | `GENERIC_READ` |
    /// | `[.write]` | `O_WRONLY` | `GENERIC_WRITE` |
    /// | `[.read, .write]` | `O_RDWR` | `GENERIC_READ \| GENERIC_WRITE` |
    ///
    /// ## See Also
    ///
    /// - ``Kernel/File/Open/Options``
    /// - ``Kernel/File/Open/open(path:mode:options:permissions:)``
    public struct Mode: OptionSet, Sendable, Hashable {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Static Members

extension Kernel.File.Open.Mode {
    /// Opens the file for reading.
    ///
    /// The file must exist unless combined with `.create` in options.
    /// Read operations (`Kernel.IO.Read.read`, `pread`) will succeed;
    /// write operations will fail with a bad file descriptor error.
    ///
    /// - POSIX: Maps to `O_RDONLY` (alone) or contributes to `O_RDWR`
    /// - Windows: Maps to `GENERIC_READ`
    public static let read = Self(rawValue: 1 << 0)

    /// Opens the file for writing.
    ///
    /// Write operations (`Kernel.IO.Write.write`, `pwrite`) will succeed.
    /// Without `.read`, read operations will fail. Combine with `.append`
    /// in options to write at end of file.
    ///
    /// - POSIX: Maps to `O_WRONLY` (alone) or contributes to `O_RDWR`
    /// - Windows: Maps to `GENERIC_WRITE` (or `FILE_APPEND_DATA` with append option)
    public static let write = Self(rawValue: 1 << 1)
}

// MARK: - POSIX Conversion

#if !os(Windows)
    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
        internal import CLinuxShim
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Kernel.File.Open.Mode {
        /// Converts the mode to POSIX open flags.
        @usableFromInline
        internal var posixFlags: Int32 {
            let hasRead = contains(.read)
            let hasWrite = contains(.write)

            if hasRead && hasWrite {
                return O_RDWR
            } else if hasWrite {
                return O_WRONLY
            } else {
                return O_RDONLY
            }
        }
    }
#endif

// MARK: - Windows Conversion

#if os(Windows)
    public import WinSDK

    extension Kernel.File.Open.Mode {
        /// Converts the mode to Windows desired access flags.
        @usableFromInline
        internal func windowsDesiredAccess(options: Kernel.File.Open.Options) -> DWORD {
            let hasRead = contains(.read)
            let hasWrite = contains(.write)
            let hasAppend = options.contains(.append)

            var access: DWORD = 0

            if hasRead {
                access |= DWORD(GENERIC_READ)
            }
            if hasWrite {
                if hasAppend {
                    // Append mode: use FILE_APPEND_DATA instead of GENERIC_WRITE
                    // This ensures all writes go to the end of the file
                    access |= DWORD(FILE_APPEND_DATA)
                } else {
                    access |= DWORD(GENERIC_WRITE)
                }
            }

            // If no mode specified, default to read
            if access == 0 {
                access = DWORD(GENERIC_READ)
            }

            return access
        }
    }
#endif
