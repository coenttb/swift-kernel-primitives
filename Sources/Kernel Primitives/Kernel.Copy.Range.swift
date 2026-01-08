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

#if os(Linux)

    #if canImport(Glibc)
        public import Glibc
        public import CLinuxShim
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Copy {
        /// Range-based copy operations using copy_file_range(2) (Linux).
        ///
        /// Enables efficient kernel-space copying between file descriptors,
        /// potentially using server-side copy for network filesystems.
        public enum Range {

        }
    }

    // MARK: - Operations

    extension Kernel.Copy.Range {
        /// Copies bytes between file descriptors using copy_file_range(2).
        ///
        /// This Linux-specific syscall performs efficient kernel-space copying,
        /// avoiding unnecessary data transfer to userspace. On supported filesystems,
        /// it may use copy-on-write or server-side copy.
        ///
        /// ## Threading
        /// This call blocks until at least some bytes are copied or an error occurs.
        /// May copy fewer bytes than requested (similar to read/write). Safe to call
        /// concurrently if operating on non-overlapping regions.
        ///
        /// ## Filesystem Support
        /// - **NFS**: Server-side copy (data doesn't traverse network twice)
        /// - **Btrfs/XFS**: May use reflinks for same-filesystem copies
        /// - **Other**: Falls back to efficient kernel-space copy
        ///
        /// ## Partial Copies
        /// May return fewer bytes than `length`. This is not an error—loop until
        /// all data is copied or the source is exhausted (returns 0).
        ///
        /// ## Errors
        /// - ``Kernel/Copy/Error/invalidDescriptor``: Source or destination is invalid
        /// - ``Kernel/Copy/Error/crossDevice``: Offload not supported across devices
        /// - ``Kernel/Copy/Error/io``: I/O error during copy
        ///
        /// - Parameters:
        ///   - source: Source file descriptor (open for reading).
        ///   - sourceOffset: Offset in source file (updated on return).
        ///   - destination: Destination file descriptor (open for writing).
        ///   - destOffset: Offset in destination file (updated on return).
        ///   - length: Maximum number of bytes to copy.
        /// - Returns: Number of bytes copied (may be less than `length`).
        /// - Throws: ``Kernel/Copy/Error`` on failure.
        @inlinable
        public static func copy(
            from source: Kernel.Descriptor,
            sourceOffset: inout Kernel.File.Offset,
            to destination: Kernel.Descriptor,
            destOffset: inout Kernel.File.Offset,
            length: Kernel.File.Size
        ) throws(Kernel.Copy.Error) -> Kernel.File.Size {
            guard source.isValid else { throw .invalidDescriptor }
            guard destination.isValid else { throw .invalidDescriptor }

            var srcOff = off_t(sourceOffset.rawValue)
            var dstOff = off_t(destOffset.rawValue)

            let result = Int(
                swift_copy_file_range(
                    source.rawValue,
                    &srcOff,
                    destination.rawValue,
                    &dstOff,
                    size_t(Int(length)),
                    0
                )
            )

            guard result >= 0 else {
                throw Kernel.Copy.Error(posix: errno)
            }

            sourceOffset = Kernel.File.Offset(Int64(srcOff))
            destOffset = Kernel.File.Offset(Int64(dstOff))
            return Kernel.File.Size(Int64(result))
        }
    }

#endif
