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
    /// File memory mapping operations.
    public enum File {}
}

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.Memory.Map.File {
        /// Maps a file into memory using Windows APIs.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor (Windows HANDLE) to map.
        ///   - offset: Offset into the file.
        ///   - length: Number of bytes to map.
        ///   - protection: Memory protection flags.
        ///   - copyOnWrite: If true, use copy-on-write semantics.
        /// - Returns: The mapped region.
        /// - Throws: `Error.map` on failure.
        public static func map(
            descriptor: Kernel.Descriptor,
            offset: Kernel.File.Offset,
            length: Kernel.File.Size,
            protection: Kernel.Memory.Map.Protection,
            copyOnWrite: Bool = false
        ) throws(Kernel.Memory.Map.Error) -> Kernel.Memory.Map.Region {
            guard length.isPositive else {
                throw .invalid(.length)
            }

            guard descriptor.isValid else {
                throw .map(.win32(UInt32(ERROR_INVALID_HANDLE)))
            }

            let fileHandle = descriptor.rawValue

            var pageProtection = protection.windowsPageProtection
            if copyOnWrite {
                if pageProtection == DWORD(PAGE_READWRITE) {
                    pageProtection = DWORD(PAGE_WRITECOPY)
                } else if pageProtection == DWORD(PAGE_EXECUTE_READWRITE) {
                    pageProtection = DWORD(PAGE_EXECUTE_WRITECOPY)
                }
            }

            let maxSize = UInt64(offset.rawValue) + UInt64(length.rawValue)
            let maxSizeHigh = DWORD(maxSize >> 32)
            let maxSizeLow = DWORD(maxSize & 0xFFFF_FFFF)

            let mappingHandle = CreateFileMappingW(
                fileHandle,
                nil,
                pageProtection,
                maxSizeHigh,
                maxSizeLow,
                nil
            )

            guard let mappingHandle, mappingHandle != INVALID_HANDLE_VALUE else {
                throw .map(.captureLastError())
            }

            var access = protection.windowsFileMapAccess
            if copyOnWrite {
                access = DWORD(FILE_MAP_COPY)
            }

            let offsetHigh = DWORD(UInt64(offset.rawValue) >> 32)
            let offsetLow = DWORD(UInt64(offset.rawValue) & 0xFFFF_FFFF)

            let viewAddress = MapViewOfFile(
                mappingHandle,
                access,
                offsetHigh,
                offsetLow,
                SIZE_T(length.rawValue)
            )

            guard let address = viewAddress else {
                CloseHandle(mappingHandle)
                throw .map(.captureLastError())
            }

            return Kernel.Memory.Map.Region(base: Kernel.Memory.Address(address), length: length, mappingHandle: mappingHandle)
        }
    }

#endif
