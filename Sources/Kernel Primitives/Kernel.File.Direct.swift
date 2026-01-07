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

public import Binary

/// Namespace for Direct I/O operations (cache bypass).
///
/// Direct I/O bypasses the operating system's page cache, allowing data to flow
/// directly between user buffers and storage. This is useful for:
/// - Database engines that manage their own caching
/// - Large sequential I/O where cache pollution is undesirable
/// - Applications requiring predictable latency
///
/// ## Platform Semantics
///
/// | Platform | Flag | Semantics | Alignment Required |
/// |----------|------|-----------|-------------------|
/// | Linux | `O_DIRECT` | Strict bypass | Yes (buffer, offset, length) |
/// | Windows | `FILE_FLAG_NO_BUFFERING` | Strict bypass | Yes (sector-aligned) |
/// | macOS | `fcntl(F_NOCACHE)` | Best-effort hint | No |
///
/// **Important:** macOS `F_NOCACHE` is a *hint*, not a strict bypass. The kernel
/// may still cache data. Use `.uncached` mode on macOS, not `.direct`.
///
/// ## Handle-Level Constraint
///
/// Direct I/O mode is set at open time (Linux/Windows) or applied post-open (macOS).
/// Once set, all operations on the handle must comply with alignment requirements.
/// Mixing buffered and direct operations on the same handle is undefined behavior.
///
/// ## Alignment Requirements
///
/// On Linux and Windows, Direct I/O requires:
/// - **Buffer alignment**: Memory address must be aligned to sector/page boundary
/// - **Offset alignment**: File offset must be aligned
/// - **Length multiple**: I/O size must be a multiple of the alignment unit
///
/// Use `Buffer.Aligned` for portable aligned buffer allocation.
///
/// ## mmap Interaction
///
/// Mixing Direct I/O and memory-mapped I/O on the same file ranges is undefined
/// behavior. The page cache coherency model does not apply when Direct I/O bypasses
/// it. If you need both, use separate file handles and explicit synchronization.
///
/// ## Usage
///
/// ```swift
/// // Open with Direct I/O (Linux/Windows)
/// let handle = try Kernel.File.open(path, mode: .readWrite, cacheMode: .direct)
///
/// // Query requirements
/// let requirements = try handle.direct.requirements()
/// guard case .known(let align) = requirements else {
///     throw Kernel.File.Direct.Error.notSupported
/// }
///
/// // Allocate aligned buffer
/// var buffer = try Buffer.Aligned(
///     byteCount: 4096,
///     alignment: align.bufferAlignment
/// )
///
/// // Read with alignment validation
/// try handle.read(into: &buffer, at: 0)
/// ```
///
/// ```swift
/// // Portable code with auto-fallback
/// let handle = try Kernel.File.open(
///     path,
///     mode: .read,
///     cacheMode: .auto(policy: .fallbackToBuffered)
/// )
/// // On macOS: uses .uncached
/// // On Linux/Windows: uses .direct if alignment satisfied, else .buffered
/// ```
extension Kernel.File {
    public enum Direct {}
}

// MARK: - Public Requirements API

extension Kernel.File.Direct {
    /// Queries alignment requirements for a file path.
    ///
    /// Use this to determine whether Direct I/O is available and what
    /// alignment constraints apply before opening a file.
    ///
    /// ## Platform Behavior
    ///
    /// - **macOS**: Always returns `.unknown(.platformUnsupported)` because
    ///   `F_NOCACHE` has no alignment requirements.
    /// - **Linux**: Returns `.unknown(.sectorSizeUndetermined)` because
    ///   alignment constraints are not reliably discoverable. See notes below.
    /// - **Windows**: Returns `.known(...)` based on sector size from
    ///   `GetDiskFreeSpaceW`, or `.unknown` for network paths.
    ///
    /// ## Linux Alignment Discovery Limitations
    ///
    /// Linux `O_DIRECT` alignment requirements are not reliably derivable from
    /// standard APIs. They vary by filesystem, device, and configuration, and
    /// are often only enforced at syscall time via `EINVAL`.
    ///
    /// For production use on Linux, either:
    /// 1. Use `.auto(.fallbackToBuffered)` for best-effort operation
    /// 2. Provide explicit alignment via `Requirements(uniformAlignment:)`
    /// 3. Handle `EINVAL` errors as potential alignment violations
    ///
    /// Common safe alignments for reference:
    /// - 512 bytes: Legacy HDDs
    /// - 4096 bytes: Modern SSDs, NVMe, most ext4/XFS
    /// - Page size: Conservative fallback (typically 4096)
    ///
    /// - Parameter path: The file path to query.
    /// - Returns: The alignment requirements, or `.unknown` with a reason.
    public static func requirements(
        for path: borrowing Kernel.Path
    ) -> Requirements {
        #if os(macOS)
            return .unknown(reason: .platformUnsupported)
        #elseif os(Linux)
            // Fail closed - alignment not reliably discoverable
            return .unknown(reason: .sectorSizeUndetermined)
        #elseif os(Windows)
            return Requirements(path)
        #else
            return .unknown(reason: .platformUnsupported)
        #endif
    }
}

// MARK: - Requirements Constructors

extension Kernel.File.Direct.Requirements {
    /// Creates known alignment requirements with explicit values.
    ///
    /// Use this when you know the specific alignment requirements for your
    /// storage configuration. This bypasses automatic discovery and allows
    /// Direct I/O on platforms where discovery fails.
    ///
    /// - Parameters:
    ///   - bufferAlignment: Required alignment for buffer addresses.
    ///   - offsetAlignment: Required alignment for file offsets.
    ///   - lengthMultiple: Required multiple for I/O lengths.
    public init(
        bufferAlignment: Binary.Alignment,
        offsetAlignment: Binary.Alignment,
        lengthMultiple: Binary.Alignment
    ) {
        self = .known(
            Alignment(
                bufferAlignment: bufferAlignment,
                offsetAlignment: offsetAlignment,
                lengthMultiple: lengthMultiple
            )
        )
    }

    /// Creates known alignment requirements with a uniform value.
    ///
    /// Convenience for when buffer, offset, and length all use the same alignment.
    ///
    /// - Parameter alignment: The uniform alignment value.
    public init(uniformAlignment alignment: Binary.Alignment) {
        self = .known(Alignment(uniform: alignment))
    }
}

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
    internal import CLinuxShim
#elseif os(Windows)
    public import WinSDK
#endif

// MARK: - macOS Implementation

#if os(macOS)
    extension Kernel.File.Direct {
        /// Sets or clears the F_NOCACHE flag on a file descriptor.
        ///
        /// F_NOCACHE is a *hint* that tells the kernel to avoid caching data
        /// for this file. Unlike Linux O_DIRECT, it does not impose alignment
        /// requirements and may not completely bypass the cache.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor.
        ///   - enabled: `true` to enable no-cache, `false` to disable.
        /// - Throws: `Error.Syscall` if fcntl fails.
        public static func setNoCache(
            descriptor: Kernel.File.Descriptor,
            enabled: Bool
        ) throws(Error.Syscall) {
            let result = fcntl(descriptor.rawValue, F_NOCACHE, enabled ? 1 : 0)
            guard result != -1 else {
                let operation: Error.Operation = enabled ? .cache(.set) : .cache(.clear)
                throw .platform(code: .posix(errno), operation: operation)
            }
        }

        /// Probes the Direct I/O capability for a path.
        ///
        /// On macOS, only `.uncached` mode (F_NOCACHE) is available.
        /// True Direct I/O with alignment requirements is not supported.
        public static func probeCapability(at path: borrowing Kernel.Path) -> Capability {
            // macOS doesn't have true Direct I/O, only F_NOCACHE hint
            // We always return .uncachedOnly since F_NOCACHE is universally available
            return .uncachedOnly
        }

        /// Gets alignment requirements for a file descriptor.
        ///
        /// On macOS, there are no alignment requirements since F_NOCACHE
        /// is a hint, not a strict bypass. Returns `.unknown(.platformUnsupported)`.
        public static func getRequirements(
            descriptor: Int32
        ) throws(Error.Syscall) -> Requirements {
            // macOS F_NOCACHE has no alignment requirements
            return .unknown(reason: .platformUnsupported)
        }
    }
#endif

// MARK: - Linux Implementation

#if os(Linux)
    extension Kernel.File.Direct {
        /// The O_DIRECT open flag value.
        ///
        /// This is the flag to pass when opening a file for Direct I/O.
        /// Note: O_DIRECT must be set at open time, not after.
        public static var openDirectFlag: Int32 {
            O_DIRECT
        }

        /// Probes the Direct I/O capability for a path.
        ///
        /// On Linux, Direct I/O is filesystem-dependent but widely supported.
        /// The main exceptions are network filesystems and some FUSE implementations.
        public static func probeCapability(at path: borrowing Kernel.Path) -> Capability {
            // Get filesystem type via statfs
            let statfsBuf: Kernel.File.System.Stats
            do {
                statfsBuf = try Kernel.File.System.Stats.get(path: path)
            } catch {
                return .bufferedOnly
            }

            // Known filesystems that DON'T support O_DIRECT well
            // NFS: 0x6969
            // CIFS: 0xFF534D42
            // tmpfs: 0x01021994
            let fsMagic = statfsBuf.type
            if fsMagic == .nfs || fsMagic == .cifs || fsMagic == .tmpfs {
                return .bufferedOnly
            }

            // For supported filesystems, check requirements
            let requirements = Requirements(path)
            if case .known(let alignment) = requirements {
                return .directSupported(alignment)
            }
            return .bufferedOnly
        }

        /// Gets alignment requirements for a file descriptor.
        ///
        /// **Important:** Linux O_DIRECT alignment constraints are not reliably
        /// derivable from `statfs` or other standard APIs. They vary by filesystem,
        /// device, and configuration, and are often only enforced at syscall time
        /// via `EINVAL`.
        ///
        /// This implementation returns `.unknown` to fail closed. Callers who need
        /// Direct I/O should either:
        /// 1. Use `.auto(.fallbackToBuffered)` for best-effort operation
        /// 2. Provide explicit alignment via `Kernel.File.open` with custom requirements
        /// 3. Handle `EINVAL` errors as potential alignment violations
        ///
        /// For reference, common safe alignments are:
        /// - 512 bytes: Legacy HDDs, some older filesystems
        /// - 4096 bytes: Modern SSDs, NVMe, most ext4/XFS configurations
        /// - Page size: Conservative fallback (typically 4096)
        public static func getRequirements(
            descriptor: Int32
        ) throws(Error.Syscall) -> Requirements {
            // Linux O_DIRECT alignment is not reliably discoverable.
            // statfs.f_bsize is the optimal transfer size, NOT the alignment requirement.
            // Actual requirements depend on device sector size, filesystem, and driver.
            //
            // Fail closed: return unknown rather than guess wrong.
            return .unknown(reason: .sectorSizeUndetermined)
        }
    }
#endif

// MARK: - Windows Implementation

#if os(Windows)
    extension Kernel.File.Direct {
        /// The FILE_FLAG_NO_BUFFERING open flag value as UInt32.
        ///
        /// This is the flag to pass when opening a file for Direct I/O.
        /// Note: Must be set at CreateFile time, not after.
        public static var openDirectFlag: UInt32 {
            UInt32(FILE_FLAG_NO_BUFFERING)
        }

        /// Probes the Direct I/O capability for a path.
        ///
        /// On Windows, NO_BUFFERING is widely supported but requires knowing
        /// the sector size for alignment. If we can't determine sector size,
        /// we report buffered-only.
        public static func probeCapability(at path: borrowing Kernel.Path) -> Capability {
            let requirements = Requirements(path)
            if case .known(let alignment) = requirements {
                return .directSupported(alignment)
            }
            return .bufferedOnly
        }

        /// Gets alignment requirements for a file handle.
        ///
        /// This is more complex on Windows as we need to get the file path
        /// from the handle first. For simplicity, we require the path to be
        /// provided at open time.
        public static func getRequirements(
            handle: UnsafeMutableRawPointer?
        ) throws(Error.Syscall) -> Requirements {
            guard handle != nil, handle != INVALID_HANDLE_VALUE else {
                throw .invalidDescriptor(operation: .sector(.getSize))
            }

            // Getting path from handle requires GetFinalPathNameByHandle
            // which adds complexity. For now, return a conservative default.
            //
            // Most modern Windows storage uses 512 or 4096 byte sectors.
            // We'll use 4096 as a safe default, but callers should prefer
            // querying with a path when possible.
            return .known(Requirements.Alignment(uniform: .`4096`))
        }
    }
#endif

// MARK: - Common Helpers

// Page size: Use `Kernel.System.pageSize` from swift-kernel
