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
        /// Range-based copy operations using copy_file_range(2).
        public enum Range {

        }
    }

    // MARK: - Operations

    extension Kernel.Copy.Range {
        /// Copies bytes between file descriptors using copy_file_range(2).
        ///
        /// This is a Linux-specific syscall that can perform efficient
        /// server-side copies on supported filesystems (e.g., NFS, Btrfs).
        ///
        /// - Parameters:
        ///   - source: Source file descriptor.
        ///   - sourceOffset: Offset in source file (updated on return).
        ///   - destination: Destination file descriptor.
        ///   - destOffset: Offset in destination file (updated on return).
        ///   - length: Maximum number of bytes to copy.
        /// - Returns: Number of bytes copied.
        /// - Throws: `Kernel.Copy.Error` on failure.
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
