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

extension Kernel.Memory.Map {
    /// Anonymous memory mapping operations.
    public enum Anonymous {}
}

// MARK: - POSIX Implementation

#if !os(Windows)

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        public import Glibc
        public import CLinuxShim
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Memory.Map.Anonymous {
        /// Maps anonymous memory.
        ///
        /// Convenience wrapper for anonymous mappings.
        ///
        /// - Parameters:
        ///   - length: Number of bytes to map.
        ///   - protection: Memory protection flags.
        ///   - shared: If true, mapping is shared; otherwise private.
        /// - Returns: The mapped region.
        /// - Throws: `Error.map` on failure.
        @inlinable
        public static func map(
            length: Kernel.File.Size,
            protection: Kernel.Memory.Map.Protection = .readWrite,
            shared: Bool = false
        ) throws(Kernel.Memory.Map.Error) -> Kernel.Memory.Map.Region {
            let flags: Kernel.Memory.Map.Flags =
                shared
                ? .shared | .anonymous
                : .private | .anonymous
            let base = try Kernel.Memory.Map.map(length: length, protection: protection, flags: flags)
            return Kernel.Memory.Map.Region(base: base, length: length)
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.Memory.Map.Anonymous {
        /// Maps anonymous memory (pagefile-backed) on Windows.
        ///
        /// - Parameters:
        ///   - length: Number of bytes to map.
        ///   - protection: Memory protection flags.
        /// - Returns: The mapped region.
        /// - Throws: `Error.map` on failure.
        public static func map(
            length: Kernel.File.Size,
            protection: Kernel.Memory.Map.Protection = .readWrite
        ) throws(Kernel.Memory.Map.Error) -> Kernel.Memory.Map.Region {
            guard length.isPositive else {
                throw .invalid(.length)
            }

            let pageProtection = protection.windowsPageProtection
            let maxSizeHigh = DWORD(UInt64(Int(length)) >> 32)
            let maxSizeLow = DWORD(UInt64(Int(length)) & 0xFFFF_FFFF)

            let mappingHandle = CreateFileMappingW(
                INVALID_HANDLE_VALUE,
                nil,
                pageProtection,
                maxSizeHigh,
                maxSizeLow,
                nil
            )

            guard let mappingHandle, mappingHandle != INVALID_HANDLE_VALUE else {
                throw .map(.captureLastError())
            }

            let access = protection.windowsFileMapAccess

            let viewAddress = MapViewOfFile(
                mappingHandle,
                access,
                0,
                0,
                SIZE_T(Int(length))
            )

            guard let address = viewAddress else {
                CloseHandle(mappingHandle)
                throw .map(.captureLastError())
            }

            return Kernel.Memory.Map.Region(base: Kernel.Memory.Address(address), length: length, mappingHandle: mappingHandle)
        }
    }

#endif
