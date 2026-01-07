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

/// Namespace for file cloning (copy-on-write reflink) operations.
///
/// File cloning creates a lightweight copy that shares storage with the original
/// until either file is modified. This is significantly faster than a byte-by-byte
/// copy for large files on supported filesystems.
///
/// ## Platform Support
///
/// | Platform | Filesystem | Mechanism |
/// |----------|------------|-----------|
/// | macOS | APFS | `clonefile()` |
/// | Linux | Btrfs, XFS | `ioctl(FICLONE)` |
/// | Linux | Any | `copy_file_range()` (may CoW) |
/// | Windows | ReFS | `FSCTL_DUPLICATE_EXTENTS_TO_FILE` |
///
/// ## Usage
///
/// ```swift
/// // Clone with fallback to copy
/// try Kernel.File.Clone.clone(
///     from: sourcePath,
///     to: destinationPath,
///     behavior: .reflinkOrCopy
/// )
///
/// // Probe capability first
/// let cap = try Kernel.File.Clone.capability(at: sourcePath)
/// if cap == .reflink {
///     try Kernel.File.Clone.clone(from: sourcePath, to: destinationPath, behavior: .reflinkOrFail)
/// }
/// ```
extension Kernel.File {
    public enum Clone {}
}

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif os(Windows)
    public import WinSDK
#endif

// MARK: - Capability Probing

extension Kernel.File.Clone.Capability {
    /// Probes whether the filesystem at the given path supports cloning.
    #if os(macOS)
        public static func probe(at path: borrowing Kernel.Path) throws(Kernel.File.Clone.Error.Syscall) -> Kernel.File.Clone.Capability {
            var statfsBuf = Darwin.statfs()
            let result = statfs(path.unsafeCString, &statfsBuf)

            guard result == 0 else {
                throw .platform(code: .posix(errno), operation: .statfs)
            }

            // APFS filesystem type
            let fsType = withUnsafeBytes(of: statfsBuf.f_fstypename) { buf in
                String(cString: buf.bindMemory(to: CChar.self).baseAddress!)
            }

            // APFS supports cloning
            if fsType == "apfs" {
                return .reflink
            }

            return .none
        }
    #elseif os(Linux)
        public static func probe(at path: borrowing Kernel.Path) throws(Kernel.File.Clone.Error.Syscall) -> Kernel.File.Clone.Capability {
            let statfsBuf: Kernel.File.System.Stats
            do {
                statfsBuf = try Kernel.File.System.Stats.get(path: path)
            } catch {
                throw .platform(code: .posix(errno), operation: .statfs)
            }

            // Known filesystems that support FICLONE
            // Btrfs: 0x9123683E
            // XFS: 0x58465342 (with reflink enabled)
            // OCFS2: 0x7461636f
            let fsMagic = statfsBuf.type
            if fsMagic == .btrfs || fsMagic == .xfs {
                return .reflink
            }

            return .none
        }
    #elseif os(Windows)
        /// Probes whether the filesystem at the given path supports cloning.
        ///
        /// On Windows, we conservatively return `.none` unless we can confirm ReFS.
        public static func probe(at path: borrowing Kernel.Path) throws(Kernel.File.Clone.Error.Syscall) -> Kernel.File.Clone.Capability {
            // Would need GetVolumeInformationW to check for ReFS
            // For now, conservatively return .none
            _ = path
            return .none
        }
    #endif
}

// MARK: - File Size Operations

extension Kernel.File.Clone {
    /// File metadata operations.
    public enum Metadata {
        /// Gets the size of a file.
        #if os(macOS)
            public static func size(at path: borrowing Kernel.Path) throws(Kernel.File.Clone.Error.Syscall) -> Int {
                var statBuf = Darwin.stat()
                let result = stat(path.unsafeCString, &statBuf)

                guard result == 0 else {
                    throw .platform(code: .posix(errno), operation: .stat)
                }

                return Int(statBuf.st_size)
            }
        #elseif os(Linux)
            public static func size(at path: borrowing Kernel.Path) throws(Kernel.File.Clone.Error.Syscall) -> Int {
                var statBuf = Glibc.stat()
                let result = stat(path.unsafeCString, &statBuf)

                guard result == 0 else {
                    throw .platform(code: .posix(errno), operation: .stat)
                }

                return Int(statBuf.st_size)
            }
        #endif

        #if os(Windows)
            public static func size(handle: UnsafeMutableRawPointer?) throws(Kernel.File.Clone.Error.Syscall) -> UInt64 {
                var size: LARGE_INTEGER = LARGE_INTEGER()
                guard GetFileSizeEx(handle, &size) else {
                    throw .platform(code: .win32(UInt32(GetLastError())), operation: .stat)
                }
                return UInt64(size.QuadPart)
            }
        #endif
    }
}

// MARK: - macOS Implementation

#if os(macOS)
    extension Kernel.File.Clone {
        /// macOS clonefile() operations.
        public enum Clonefile {
            /// Attempts to clone a file using clonefile().
            ///
            /// - Parameters:
            ///   - source: Source file path.
            ///   - destination: Destination file path.
            /// - Returns: `true` if cloned, `false` if not supported.
            /// - Throws: `Kernel.File.Clone.Error.Syscall` for other errors.
            public static func attempt(
                source: borrowing Kernel.Path,
                destination: borrowing Kernel.Path
            ) throws(Kernel.File.Clone.Error.Syscall) -> Bool {
                let result = clonefile(source.unsafeCString, destination.unsafeCString, 0)

                if result == 0 {
                    return true
                }

                let err = errno
                // ENOTSUP means filesystem doesn't support cloning
                if err == ENOTSUP {
                    return false
                }

                throw .platform(code: .posix(err), operation: .clonefile)
            }
        }

        /// macOS copyfile() operations.
        public enum Copyfile {
            /// Copies a file using copyfile() with COPYFILE_CLONE flag.
            ///
            /// This attempts CoW clone first, falls back to copy.
            public static func clone(
                source: borrowing Kernel.Path,
                destination: borrowing Kernel.Path
            ) throws(Kernel.File.Clone.Error.Syscall) {
                // Check if destination exists first (copyfile doesn't fail by default)
                var statBuf = Darwin.stat()
                let destExists = stat(destination.unsafeCString, &statBuf) == 0
                if destExists {
                    throw .platform(code: .posix(EEXIST), operation: .copyfile)
                }

                let result = copyfile(source.unsafeCString, destination.unsafeCString, nil, copyfile_flags_t(COPYFILE_CLONE | COPYFILE_ALL))

                guard result == 0 else {
                    throw .platform(code: .posix(errno), operation: .copyfile)
                }
            }

            /// Copies a file using copyfile() without clone attempt.
            public static func data(
                source: borrowing Kernel.Path,
                destination: borrowing Kernel.Path
            ) throws(Kernel.File.Clone.Error.Syscall) {
                // Check if destination exists first (copyfile doesn't fail by default)
                var statBuf = Darwin.stat()
                let destExists = stat(destination.unsafeCString, &statBuf) == 0
                if destExists {
                    throw .platform(code: .posix(EEXIST), operation: .copyfile)
                }

                let result = copyfile(source.unsafeCString, destination.unsafeCString, nil, copyfile_flags_t(COPYFILE_DATA))

                guard result == 0 else {
                    throw .platform(code: .posix(errno), operation: .copyfile)
                }
            }
        }
    }
#endif

// MARK: - Linux Implementation

#if os(Linux)
    // ioctl request code for FICLONE
    private let FICLONE: UInt = 0x4004_9409

    extension Kernel.File.Clone {
        /// Linux FICLONE operations.
        public enum Ficlone {
            /// Attempts to clone a file using ioctl(FICLONE).
            ///
            /// - Parameters:
            ///   - source: Source file descriptor.
            ///   - destination: Destination file descriptor.
            /// - Returns: `true` if cloned, `false` if not supported.
            /// - Throws: `Kernel.File.Clone.Error.Syscall` for other errors.
            public static func attempt(
                source: Kernel.Descriptor,
                destination: Kernel.Descriptor
            ) throws(Kernel.File.Clone.Error.Syscall) -> Bool {
                let result = ioctl(destination.rawValue, FICLONE, source.rawValue)

                if result == 0 {
                    return true
                }

                let err = errno
                // EOPNOTSUPP/ENOTSUP means filesystem doesn't support cloning
                if err == EOPNOTSUPP || err == ENOTSUP || err == EINVAL || err == EXDEV {
                    return false
                }

                throw .platform(code: .posix(err), operation: .ficlone)
            }
        }

        /// Linux copy_file_range operations.
        public enum CopyRange {
            /// Copies file data using copy_file_range().
            ///
            /// This may use server-side copy or reflink on supported filesystems.
            public static func copy(
                source: Kernel.Descriptor,
                destination: Kernel.Descriptor,
                length: Int
            ) throws(Kernel.File.Clone.Error.Syscall) {
                var remaining = Kernel.File.Size(length)
                var srcOffset = Kernel.File.Offset(0)
                var dstOffset = Kernel.File.Offset(0)

                while remaining > .zero {
                    let copied: Kernel.File.Size
                    do {
                        copied = try Kernel.Copy.Range.copy(
                            from: source,
                            sourceOffset: &srcOffset,
                            to: destination,
                            destOffset: &dstOffset,
                            length: remaining
                        )
                    } catch {
                        throw .platform(code: .posix(errno), operation: .copyFileRange)
                    }

                    if copied == .zero {
                        break  // EOF
                    }

                    remaining -= copied
                }
            }
        }
    }
#endif

// MARK: - Windows Implementation

#if os(Windows)
    extension Kernel.File.Clone {
        /// Windows extent duplication operations.
        public enum Extents {
            /// Attempts to duplicate file extents (ReFS block clone).
            ///
            /// This is highly constrained: same volume, ReFS only, specific alignment.
            /// Returns `false` if unsupported rather than erroring.
            public static func attempt(
                sourceHandle: UnsafeMutableRawPointer?,
                destHandle: UnsafeMutableRawPointer?,
                length: UInt64
            ) throws(Kernel.File.Clone.Error.Syscall) -> Bool {
                // ReFS block cloning requires FSCTL_DUPLICATE_EXTENTS_TO_FILE
                // This is complex and has many constraints, so we'll return false
                // for now and rely on CopyFile2 as the fallback.
                //
                // Full implementation would need:
                // - Verify both on same ReFS volume
                // - Align to cluster size
                // - Use DeviceIoControl with FSCTL_DUPLICATE_EXTENTS_TO_FILE
                _ = sourceHandle
                _ = destHandle
                _ = length
                return false
            }
        }

        /// Windows file copy operations.
        public enum Copy {
            /// Copies a file using CopyFileW.
            public static func file(
                source: borrowing Kernel.Path,
                destination: borrowing Kernel.Path
            ) throws(Kernel.File.Clone.Error.Syscall) {
                let result = CopyFileW(source.unsafeCString, destination.unsafeCString, true)

                guard result else {
                    throw .platform(code: .win32(UInt32(GetLastError())), operation: .copy)
                }
            }
        }
    }
#endif
