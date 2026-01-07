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
    /// Options that modify file opening behavior.
    ///
    /// These portable flags control creation, truncation, access patterns, and other
    /// behaviors. They map to platform-specific values internally (`O_*` on POSIX,
    /// various Windows flags).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Create a new file, fail if it exists
    /// let fd = try Kernel.File.Open.open(
    ///     path: "/tmp/output.txt",
    ///     mode: [.write],
    ///     options: [.create, .exclusive]
    /// )
    /// defer { try? Kernel.Close.close(fd) }
    ///
    /// // Open for append (logging pattern)
    /// let logFd = try Kernel.File.Open.open(
    ///     path: "/var/log/app.log",
    ///     mode: [.write],
    ///     options: [.create, .append]
    /// )
    ///
    /// // Overwrite existing file
    /// let fd = try Kernel.File.Open.open(
    ///     path: "data.bin",
    ///     mode: [.write],
    ///     options: [.create, .truncate]
    /// )
    /// ```
    ///
    /// ## Common Combinations
    ///
    /// | Pattern | Options |
    /// |---------|---------|
    /// | New file (fail if exists) | `[.create, .exclusive]` |
    /// | Overwrite or create | `[.create, .truncate]` |
    /// | Append or create | `[.create, .append]` |
    /// | Open existing only | `[]` |
    ///
    /// ## See Also
    ///
    /// - ``Kernel/File/Open/Mode``
    /// - ``Kernel/File/Open/open(path:mode:options:permissions:)``
    public struct Options: OptionSet, Sendable, Hashable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Standard Options

extension Kernel.File.Open.Options {
    /// Creates the file if it does not exist.
    ///
    /// If the file exists, open succeeds without modification.
    /// Combine with `.exclusive` to fail if the file already exists.
    /// Combine with `.truncate` to overwrite existing content.
    /// When creating, the `permissions` parameter sets initial file permissions.
    ///
    /// - POSIX: `O_CREAT`
    /// - Windows: `CREATE_NEW` or `OPEN_ALWAYS` (combined with other flags)
    public static let create = Self(rawValue: 1 << 0)

    /// Truncates the file to zero length if it exists.
    ///
    /// All existing content is discarded. The file offset is set to 0.
    /// Has no effect if the file doesn't exist (combine with `.create` for that).
    /// Requires write mode.
    ///
    /// - POSIX: `O_TRUNC`
    /// - Windows: `TRUNCATE_EXISTING` or `CREATE_ALWAYS` (combined with other flags)
    public static let truncate = Self(rawValue: 1 << 1)

    /// Positions all writes at the end of file.
    ///
    /// Each write atomically appends data regardless of file offset.
    /// Useful for log files where multiple processes may write concurrently.
    /// The file offset is still updated, so reads will see the new position.
    ///
    /// - POSIX: `O_APPEND`
    /// - Windows: `FILE_APPEND_DATA` access mode
    public static let append = Self(rawValue: 1 << 2)

    /// Fails if the file already exists.
    ///
    /// Only meaningful with `.create`. Together they atomically create
    /// a new file or fail, preventing race conditions where two processes
    /// might both "win" the create.
    ///
    /// - POSIX: `O_EXCL`
    /// - Windows: `CREATE_NEW`
    public static let exclusive = Self(rawValue: 1 << 3)

    /// Requests direct I/O (bypass page cache).
    ///
    /// Data transfers directly between user buffers and storage, bypassing
    /// the kernel's page cache. Useful for databases and applications that
    /// manage their own caching.
    ///
    /// **Alignment requirements apply.** On Linux, buffers, offsets, and lengths
    /// must typically be aligned to the filesystem's block size (often 512 or 4096).
    /// On macOS, direct I/O is advisory (via `F_NOCACHE`). On Windows, alignment
    /// to the volume sector size is required.
    ///
    /// - POSIX (Linux): `O_DIRECT`
    /// - macOS: No direct flag; use `fcntl(F_NOCACHE)` after open
    /// - Windows: `FILE_FLAG_NO_BUFFERING`
    ///
    /// - Note: Higher layers (swift-io) handle capability probing and
    ///   alignment validation.
    public static let direct = Self(rawValue: 1 << 6)

    /// Does not follow symlinks when opening.
    ///
    /// Security feature to prevent symlink attacks. If the final path component
    /// is a symbolic link, the open fails instead of following it.
    ///
    /// - POSIX: `O_NOFOLLOW` - fails with `ELOOP` if path is a symlink
    /// - Windows: `FILE_FLAG_OPEN_REPARSE_POINT` - opens the reparse point itself
    ///
    /// - Note: Intermediate symlinks in the path are still followed; only the
    ///   final component is affected.
    public static let noFollow = Self(rawValue: 1 << 8)
}

// MARK: - Internal Constants

extension Kernel.File.Open.Options {
    // Internal bit positions for behavior options
    @usableFromInline
    internal static let execClose = Self(rawValue: 1 << 4)
    @usableFromInline
    internal static let blockingDisabled = Self(rawValue: 1 << 5)
    @usableFromInline
    internal static let cacheDisabled = Self(rawValue: 1 << 7)
}

// MARK: - POSIX Conversion

#if !os(Windows)
    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        public import Glibc
        public import CLinuxShim
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Kernel.File.Open.Options {
        /// Converts the options to POSIX open flags.
        @usableFromInline
        internal var posixFlags: Int32 {
            var flags: Int32 = 0

            if contains(.create) {
                flags |= O_CREAT
            }
            if contains(.truncate) {
                flags |= O_TRUNC
            }
            if contains(.append) {
                flags |= O_APPEND
            }
            if contains(.exclusive) {
                flags |= O_EXCL
            }
            if contains(.execClose) {
                flags |= O_CLOEXEC
            }
            if contains(.blockingDisabled) {
                flags |= O_NONBLOCK
            }
            #if os(Linux)
                if contains(.direct) {
                    flags |= O_DIRECT
                }
            #endif
            if contains(.noFollow) {
                flags |= O_NOFOLLOW
            }

            return flags
        }
    }
#endif

// MARK: - Windows Conversion

#if os(Windows)
    public import WinSDK

    extension Kernel.File.Open.Options {
        /// Converts the options to Windows creation disposition.
        @usableFromInline
        internal var windowsCreationDisposition: DWORD {
            let hasCreate = contains(.create)
            let hasExclusive = contains(.exclusive)
            let hasTruncate = contains(.truncate)

            if hasCreate && hasExclusive {
                return DWORD(CREATE_NEW)
            } else if hasCreate && hasTruncate {
                return DWORD(CREATE_ALWAYS)
            } else if hasCreate {
                return DWORD(OPEN_ALWAYS)
            } else if hasTruncate {
                return DWORD(TRUNCATE_EXISTING)
            } else {
                return DWORD(OPEN_EXISTING)
            }
        }

        /// Converts the options to Windows flags and attributes.
        @usableFromInline
        internal var windowsFlagsAndAttributes: DWORD {
            var flags: DWORD = DWORD(FILE_ATTRIBUTE_NORMAL)

            if contains(.direct) {
                flags |= DWORD(FILE_FLAG_NO_BUFFERING)
            }
            if contains(.noFollow) {
                flags |= DWORD(FILE_FLAG_OPEN_REPARSE_POINT)
            }

            return flags
        }

        /// Windows share mode for open operations.
        ///
        /// Default: `FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE`
        ///
        /// This is a documented stability guarantee matching common POSIX expectations.
        @usableFromInline
        internal static var windowsShareMode: DWORD {
            return DWORD(FILE_SHARE_READ) | DWORD(FILE_SHARE_WRITE) | DWORD(FILE_SHARE_DELETE)
        }
    }
#endif
