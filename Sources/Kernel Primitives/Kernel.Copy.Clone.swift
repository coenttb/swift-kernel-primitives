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

// MARK: - Linux Implementation

#if os(Linux)

    #if canImport(Glibc)
        public import Glibc
        public import CLinuxShim
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Copy {
        /// Clone operations using FICLONE ioctl (Linux).
        ///
        /// Creates copy-on-write clones where supported, sharing data blocks
        /// until either file is modified.
        public enum Clone {

        }
    }

    // MARK: - Operations

    extension Kernel.Copy.Clone {
        /// Clones a file using FICLONE ioctl, creating a copy-on-write duplicate.
        ///
        /// Both files share the same data blocks until one is modified, making this
        /// extremely fast for large files on supported filesystems.
        ///
        /// ## Threading
        /// This call blocks until the clone operation completes. The clone is atomic
        /// from the filesystem's perspective.
        ///
        /// ## Filesystem Support
        /// Only works on filesystems with reflink capability:
        /// - Btrfs (full support)
        /// - XFS (with reflink enabled)
        ///
        /// ## Errors
        /// - ``Kernel/Copy/Error/invalidDescriptor``: Source or destination is invalid
        /// - ``Kernel/Copy/Error/unsupported``: Filesystem doesn't support FICLONE
        /// - ``Kernel/Copy/Error/crossDevice``: Source and destination on different filesystems
        /// - ``Kernel/Copy/Error/notEmpty``: Destination file is not empty
        ///
        /// - Parameters:
        ///   - source: Source file descriptor (open for reading).
        ///   - destination: Destination file descriptor (must be empty, open for writing).
        /// - Throws: ``Kernel/Copy/Error`` on failure.
        @inlinable
        public static func perform(
            from source: Kernel.Descriptor,
            to destination: Kernel.Descriptor
        ) throws(Kernel.Copy.Error) {
            guard source.isValid else { throw .invalidDescriptor }
            guard destination.isValid else { throw .invalidDescriptor }

            let result = swift_ficlone(destination.rawValue, source.rawValue)
            guard result == 0 else {
                throw Kernel.Copy.Error(posix: errno)
            }
        }
    }

#endif

// MARK: - Darwin Implementation

#if canImport(Darwin)

    public import Darwin

    extension Kernel.Copy {
        /// Clone operations using clonefile(2) (macOS).
        ///
        /// Creates copy-on-write clones on APFS, sharing data blocks until
        /// either file is modified.
        public enum Clone {

        }
    }

    // MARK: - Operations

    extension Kernel.Copy.Clone {
        /// Clones a file using clonefile(2), creating a copy-on-write duplicate.
        ///
        /// Both files share the same data blocks until one is modified, making this
        /// extremely fast for large files on APFS.
        ///
        /// ## Threading
        /// This call blocks until the clone operation completes. The clone is atomic.
        ///
        /// ## Filesystem Support
        /// Only works on APFS. Falls back to regular copy on HFS+ or other filesystems.
        ///
        /// ## Errors
        /// - ``Kernel/Copy/Error/notFound``: Source file doesn't exist
        /// - ``Kernel/Copy/Error/exists``: Destination path already exists
        /// - ``Kernel/Copy/Error/permission``: Insufficient permissions
        /// - ``Kernel/Copy/Error/unsupported``: Filesystem doesn't support clonefile
        ///
        /// - Parameters:
        ///   - sourcePath: Path to source file.
        ///   - destPath: Path for destination file (must not exist).
        /// - Throws: ``Kernel/Copy/Error`` on failure.
        @inlinable
        public static func file(
            from sourcePath: String,
            to destPath: String
        ) throws(Kernel.Copy.Error) {
            let result = sourcePath.withCString { src in
                destPath.withCString { dst in
                    Darwin.clonefile(src, dst, 0)
                }
            }
            guard result == 0 else {
                throw Kernel.Copy.Error(posix: errno)
            }
        }
    }

#endif
