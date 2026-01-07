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
        /// Clone operations using FICLONE ioctl.
        public enum Clone {

        }
    }

    // MARK: - Operations

    extension Kernel.Copy.Clone {
        /// Clones a file using FICLONE ioctl.
        ///
        /// Creates a copy-on-write clone of the source file. Both files
        /// share the same data blocks until one is modified.
        ///
        /// Only supported on filesystems with reflink capability (Btrfs, XFS with reflink).
        ///
        /// - Parameters:
        ///   - source: Source file descriptor.
        ///   - destination: Destination file descriptor (must be empty).
        /// - Throws: `Kernel.Copy.Error` on failure.
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
        /// Clone operations using clonefile(2).
        public enum Clone {

        }
    }

    // MARK: - Operations

    extension Kernel.Copy.Clone {
        /// Clones a file using clonefile(2).
        ///
        /// Creates a copy-on-write clone of the source file on APFS.
        ///
        /// - Parameters:
        ///   - sourcePath: Path to source file.
        ///   - destPath: Path for destination file (must not exist).
        /// - Throws: `Kernel.Copy.Error` on failure.
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
