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

import Binary
public import Dimension

extension Kernel.Memory {
    /// Raw memory mapping syscall wrappers.
    ///
    /// Memory mapping allows files and anonymous memory to be mapped
    /// directly into the process address space for efficient I/O.
    ///
    /// This namespace provides policy-free syscall wrappers.
    /// Higher layers (swift-mmap, swift-io) build region management,
    /// lock coordination, and RAII semantics on top of these primitives.
    public enum Map {}
}

#if !os(Windows)

    #if canImport(Darwin)
        public import Darwin
    #elseif canImport(Glibc)
        public import Glibc
        public import CLinuxShim
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Memory.Map {
        /// Maps memory into the process address space.
        ///
        /// - Parameters:
        ///   - addr: Suggested address, or `nil` for kernel to choose.
        ///   - length: Number of bytes to map (must be > 0).
        ///   - protection: Memory protection flags.
        ///   - flags: Mapping flags.
        ///   - fd: File descriptor to map, or -1 for anonymous.
        ///   - offset: Offset into the file (must be page-aligned).
        /// - Returns: Pointer to the mapped region.
        /// - Throws: `Error.map` on failure.
        @inlinable
        public static func map(
            addr: Kernel.Memory.Address? = nil,
            length: Kernel.File.Size,
            protection: Protection,
            flags: Flags,
            fd: Kernel.Descriptor = .invalid,
            offset: Kernel.File.Offset = .zero
        ) throws(Error) -> Kernel.Memory.Address {
            guard length.isPositive else {
                throw .invalid(.length)
            }

            let result = mmap(
                addr?.mutablePointer,
                Int(length),
                protection.rawValue,
                flags.rawValue,
                fd.rawValue,
                off_t(offset.rawValue)
            )

            guard result != MAP_FAILED else {
                throw .map(.captureErrno())
            }

            return Kernel.Memory.Address(result!)
        }

        /// Unmaps a previously mapped region.
        ///
        /// - Parameters:
        ///   - addr: The base address of the mapping.
        ///   - length: The length of the mapping.
        /// - Throws: `Error.unmap` on failure.
        @inlinable
        public static func unmap(
            addr: Kernel.Memory.Address,
            length: Kernel.File.Size
        ) throws(Error) {
            guard munmap(addr.mutablePointer, Int(length)) == 0 else {
                throw .unmap(.captureErrno())
            }
        }

        /// Unmaps a mapped region.
        ///
        /// - Parameter region: The region to unmap.
        /// - Throws: `Error.unmap` on failure.
        @inlinable
        public static func unmap(_ region: Region) throws(Error) {
            try unmap(addr: region.base, length: region.length)
        }

        /// Synchronizes a mapped region to disk.
        ///
        /// - Parameters:
        ///   - addr: The base address of the region.
        ///   - length: The length of the region.
        ///   - flags: Sync flags (sync, async, invalidate).
        /// - Throws: `Error.sync` on failure.
        @inlinable
        public static func sync(
            addr: Kernel.Memory.Address,
            length: Kernel.File.Size,
            flags: Sync.Flags = .sync
        ) throws(Error) {
            guard msync(addr.mutablePointer, Int(length), flags.rawValue) == 0 else {
                throw .sync(.captureErrno())
            }
        }

        /// Changes the protection on a mapped region.
        ///
        /// - Parameters:
        ///   - addr: The base address (must be page-aligned).
        ///   - length: The length of the region.
        ///   - protection: The new protection flags.
        /// - Throws: `Error.protect` on failure.
        @inlinable
        public static func protect(
            addr: Kernel.Memory.Address,
            length: Kernel.File.Size,
            protection: Protection
        ) throws(Error) {
            guard mprotect(addr.mutablePointer, Int(length), protection.rawValue) == 0 else {
                throw .protect(.captureErrno())
            }
        }

        /// Advises the kernel about expected access patterns.
        ///
        /// This is advisory only; errors are ignored.
        ///
        /// - Parameters:
        ///   - addr: The base address.
        ///   - length: The length of the region.
        ///   - advice: The advice type.
        @inlinable
        public static func advise(
            addr: Kernel.Memory.Address,
            length: Kernel.File.Size,
            advice: Advice
        ) {
            _ = madvise(addr.mutablePointer, Int(length), advice.rawValue)
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.Memory.Map {
        /// Unmaps a mapped region on Windows.
        ///
        /// - Parameter region: The region to unmap.
        /// - Throws: `Error.unmap` on failure.
        public static func unmap(_ region: Region) throws(Error) {
            let unmapResult = UnmapViewOfFile(region.base.pointer)
            CloseHandle(region.mappingHandle)

            guard unmapResult else {
                throw .unmap(.captureLastError())
            }
        }

        /// Flushes a mapped view to disk on Windows.
        ///
        /// - Parameters:
        ///   - addr: The base address.
        ///   - length: The length of the region.
        /// - Throws: `Error.sync` on failure.
        public static func sync(
            addr: Kernel.Memory.Address,
            length: Kernel.File.Size
        ) throws(Error) {
            guard FlushViewOfFile(addr.pointer, SIZE_T(Int(length))) else {
                throw .sync(.captureLastError())
            }
        }

        /// Changes memory protection on Windows.
        ///
        /// - Parameters:
        ///   - addr: The base address.
        ///   - length: The length of the region.
        ///   - protection: The new protection flags.
        /// - Throws: `Error.protect` on failure.
        public static func protect(
            addr: Kernel.Memory.Address,
            length: Kernel.File.Size,
            protection: Protection
        ) throws(Error) {
            var oldProtection: DWORD = 0
            guard
                VirtualProtect(
                    addr.mutablePointer,
                    SIZE_T(Int(length)),
                    protection.windowsPageProtection,
                    &oldProtection
                )
            else {
                throw .protect(.captureLastError())
            }
        }

        /// Advises the system about access patterns on Windows.
        ///
        /// Windows has limited madvise-equivalent functionality.
        /// This is currently a no-op.
        public static func advise(
            addr: Kernel.Memory.Address,
            length: Kernel.File.Size,
            advice: Advice
        ) {
            // Windows doesn't have direct madvise equivalent
            // PrefetchVirtualMemory requires Windows 8+ and complex setup
        }
    }

#endif
