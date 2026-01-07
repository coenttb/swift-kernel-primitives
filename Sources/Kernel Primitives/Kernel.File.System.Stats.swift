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

extension Kernel.File.System {
    /// Filesystem statistics.
    ///
    /// Used by higher layers (swift-io) for Direct I/O capability probing
    /// and filesystem type detection.
    ///
    /// ## Platform Differences
    ///
    /// The `type` field has different semantics across platforms:
    /// - **POSIX**: Filesystem magic number (e.g., 0x9123683E for Btrfs, 0x58465342 for XFS).
    ///   Use this to detect filesystem capabilities.
    /// - **Windows**: Volume serial number, which identifies a specific volume instance.
    ///   Use `fsTypeName` (e.g., "NTFS", "FAT32") for filesystem type detection on Windows.
    ///
    /// For cross-platform filesystem type detection, prefer `fsTypeName` when available,
    /// falling back to `type` magic number comparison on POSIX systems.
    public struct Stats: Sendable, Equatable, Hashable {
        /// Filesystem type identifier.
        ///
        /// - POSIX: `f_type` — Filesystem magic number (e.g., 0x9123683E for Btrfs).
        ///   These values are platform-specific and can be used to detect filesystem capabilities.
        /// - Windows: Volume serial number, which identifies the volume instance.
        ///   **Note**: This is NOT a filesystem type. Use `fsTypeName` for type detection on Windows.
        ///
        /// - Important: The semantic meaning differs between platforms. For portable
        ///   filesystem type detection, use `fsTypeName` when available.
        public let type: Kernel.File.System.Kind

        /// Optimal transfer block size in bytes.
        public let blockSize: Kernel.File.System.Block.Size

        /// Total data blocks in filesystem.
        public let blocks: Kernel.File.System.Block.Count

        /// Free blocks in filesystem.
        public let freeBlocks: Kernel.File.System.Block.Count

        /// Free blocks available to unprivileged user.
        public let availableBlocks: Kernel.File.System.Block.Count

        /// Total file nodes (inodes) in filesystem.
        public let files: Kernel.File.System.File.Count

        /// Free file nodes in filesystem.
        public let freeFiles: Kernel.File.System.File.Count

        /// Filesystem ID.
        public let fsid: Kernel.File.System.ID

        /// Maximum length of filenames.
        public let nameMax: Kernel.File.System.Name.Length

        /// Filesystem type name.
        ///
        /// - Darwin: `f_fstypename` (e.g., "apfs", "hfs", "nfs")
        /// - Linux: Not available (derived from `type` if needed)
        /// - Windows: Filesystem name from `GetVolumeInformationW` (e.g., "NTFS", "FAT32")
        ///
        /// This field is `nil` when the filesystem type name is not available.
        public let fsTypeName: String?

        /// Creates filesystem statistics with the given values.
        public init(
            type: Kernel.File.System.Kind,
            blockSize: Kernel.File.System.Block.Size,
            blocks: Kernel.File.System.Block.Count,
            freeBlocks: Kernel.File.System.Block.Count,
            availableBlocks: Kernel.File.System.Block.Count,
            files: Kernel.File.System.File.Count,
            freeFiles: Kernel.File.System.File.Count,
            fsid: Kernel.File.System.ID,
            nameMax: Kernel.File.System.Name.Length,
            fsTypeName: String? = nil
        ) {
            self.type = type
            self.blockSize = blockSize
            self.blocks = blocks
            self.freeBlocks = freeBlocks
            self.availableBlocks = availableBlocks
            self.files = files
            self.freeFiles = freeFiles
            self.fsid = fsid
            self.nameMax = nameMax
            self.fsTypeName = fsTypeName
        }
    }
}

// MARK: - POSIX Implementation

#if !os(Windows)

    #if canImport(Darwin)
        public import Darwin

        @usableFromInline
        internal typealias PlatformStatfs = Darwin.statfs
    #elseif canImport(Glibc)
        public import Glibc
        public import CLinuxShim

        @usableFromInline
        internal typealias PlatformStatfs = statfs
    #elseif canImport(Musl)
        public import Musl

        @usableFromInline
        internal typealias PlatformStatfs = statfs
    #endif

    extension Kernel.File.System.Stats {
        /// Gets filesystem statistics for a path.
        ///
        /// - Parameter path: The path to get statistics for.
        /// - Returns: The filesystem statistics.
        /// - Throws: `Kernel.File.System.Stats.Error` on failure.
        @inlinable
        public static func get(path: borrowing Kernel.Path) throws(Error) -> Kernel.File.System.Stats {
            try get(unsafePath: path.unsafeCString)
        }

        /// Gets filesystem statistics for an unsafe path pointer.
        ///
        /// - Parameter unsafePath: A null-terminated C string path.
        /// - Returns: The filesystem statistics.
        /// - Throws: `Kernel.File.System.Stats.Error` on failure.
        @inlinable
        public static func get(unsafePath: UnsafePointer<Kernel.Path.Char>) throws(Error) -> Kernel.File.System.Stats {
            var buf = PlatformStatfs()
            try Kernel.Syscall.require(statfs(unsafePath, &buf), .equals(0), orThrow: Error.current())
            return Kernel.File.System.Stats(from: buf)
        }

        /// Gets filesystem statistics for a file descriptor.
        ///
        /// - Parameter descriptor: The file descriptor to get statistics for.
        /// - Returns: The filesystem statistics.
        /// - Throws: `Kernel.File.System.Stats.Error` on failure.
        @inlinable
        public static func get(descriptor: Kernel.Descriptor) throws(Error) -> Kernel.File.System.Stats {
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }
            var buf = PlatformStatfs()
            try Kernel.Syscall.require(fstatfs(descriptor.rawValue, &buf), .equals(0), orThrow: Error.current())
            return Kernel.File.System.Stats(from: buf)
        }

        /// Creates filesystem statistics from the platform's statfs struct.
        @usableFromInline
        init(from buf: PlatformStatfs) {
            #if canImport(Darwin)
                self.init(
                    type: Kernel.File.System.Kind(UInt64(buf.f_type)),
                    blockSize: Kernel.File.System.Block.Size(UInt64(buf.f_bsize)),
                    blocks: Kernel.File.System.Block.Count(UInt64(buf.f_blocks)),
                    freeBlocks: Kernel.File.System.Block.Count(UInt64(buf.f_bfree)),
                    availableBlocks: Kernel.File.System.Block.Count(UInt64(buf.f_bavail)),
                    files: Kernel.File.System.File.Count(UInt64(buf.f_files)),
                    freeFiles: Kernel.File.System.File.Count(UInt64(buf.f_ffree)),
                    fsid: Kernel.File.System.ID(UInt64(buf.f_fsid.val.0) | (UInt64(buf.f_fsid.val.1) << 32)),
                    nameMax: Kernel.File.System.Name.Length(UInt64(NAME_MAX)),
                    fsTypeName: withUnsafeBytes(of: buf.f_fstypename) { ptr in
                        String(cString: ptr.baseAddress!.assumingMemoryBound(to: CChar.self))
                    }
                )
            #else
                self.init(
                    type: Kernel.File.System.Kind(UInt64(bitPattern: Int64(buf.f_type))),
                    blockSize: Kernel.File.System.Block.Size(UInt64(buf.f_bsize)),
                    blocks: Kernel.File.System.Block.Count(UInt64(buf.f_blocks)),
                    freeBlocks: Kernel.File.System.Block.Count(UInt64(buf.f_bfree)),
                    availableBlocks: Kernel.File.System.Block.Count(UInt64(buf.f_bavail)),
                    files: Kernel.File.System.File.Count(UInt64(buf.f_files)),
                    freeFiles: Kernel.File.System.File.Count(UInt64(buf.f_ffree)),
                    fsid: Kernel.File.System.ID(UInt64(buf.f_fsid.__val.0) | (UInt64(buf.f_fsid.__val.1) << 32)),
                    nameMax: Kernel.File.System.Name.Length(UInt64(buf.f_namelen)),
                    fsTypeName: nil
                )
            #endif
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.File.System.Stats {
        /// Gets filesystem statistics for a path.
        ///
        /// - Parameter path: The path to get statistics for.
        /// - Returns: The filesystem statistics.
        /// - Throws: `Kernel.File.System.Stats.Error` on failure.
        @inlinable
        public static func get(path: borrowing Kernel.Path) throws(Error) -> Kernel.File.System.Stats {
            try get(unsafePath: path.unsafeCString)
        }

        /// Gets filesystem statistics for an unsafe path pointer.
        ///
        /// - Parameter unsafePath: A null-terminated wide string path.
        /// - Returns: The filesystem statistics.
        /// - Throws: `Kernel.File.System.Stats.Error` on failure.
        @inlinable
        public static func get(unsafePath: UnsafePointer<Kernel.Path.Char>) throws(Error) -> Kernel.File.System.Stats {
            var sectorsPerCluster: DWORD = 0
            var bytesPerSector: DWORD = 0
            var freeClusters: DWORD = 0
            var totalClusters: DWORD = 0

            try Kernel.Syscall.require(
                GetDiskFreeSpaceW(unsafePath, &sectorsPerCluster, &bytesPerSector, &freeClusters, &totalClusters),
                .isTrue,
                orThrow: Error.current()
            )

            let blockSize = UInt64(sectorsPerCluster) * UInt64(bytesPerSector)

            // Get volume information for type name
            var volumeSerial: DWORD = 0
            var maxComponentLength: DWORD = 0
            var fsFlags: DWORD = 0
            var fsNameBuffer = [WCHAR](repeating: 0, count: 256)

            let gotVolumeInfo = GetVolumeInformationW(
                unsafePath,
                nil,
                0,
                &volumeSerial,
                &maxComponentLength,
                &fsFlags,
                &fsNameBuffer,
                DWORD(fsNameBuffer.count)
            )

            let fsTypeName: String? =
                gotVolumeInfo
                ? {
                    if let nullIndex = fsNameBuffer.firstIndex(of: 0) {
                        return String(decoding: fsNameBuffer[..<nullIndex], as: UTF16.self)
                    }
                    return String(decoding: fsNameBuffer, as: UTF16.self)
                }() : nil

            return Kernel.File.System.Stats(
                type: Kernel.File.System.Kind(UInt64(volumeSerial)),
                blockSize: Kernel.File.System.Block.Size(blockSize),
                blocks: Kernel.File.System.Block.Count(UInt64(totalClusters)),
                freeBlocks: Kernel.File.System.Block.Count(UInt64(freeClusters)),
                availableBlocks: Kernel.File.System.Block.Count(UInt64(freeClusters)),
                files: Kernel.File.System.File.Count(0),
                freeFiles: Kernel.File.System.File.Count(0),
                fsid: Kernel.File.System.ID(UInt64(volumeSerial)),
                nameMax: Kernel.File.System.Name.Length(UInt64(maxComponentLength)),
                fsTypeName: fsTypeName
            )
        }
    }
#endif
