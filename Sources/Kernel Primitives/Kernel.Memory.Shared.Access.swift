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

extension Kernel.Memory.Shared {
    /// Access mode for shared memory objects.
    ///
    /// Specifies whether the shared memory is opened for reading,
    /// writing, or both.
    public struct Access: OptionSet, Sendable, Equatable, Hashable {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Open for reading.
        public static let read = Self(rawValue: 1 << 0)

        /// Open for writing.
        public static let write = Self(rawValue: 1 << 1)
    }
}

// MARK: - POSIX Conversion

#if !os(Windows)

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        public import Glibc
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Memory.Shared.Access {
        /// Converts the access mode to POSIX open flags.
        @usableFromInline
        internal var posixFlags: Int32 {
            let hasRead = contains(.read)
            let hasWrite = contains(.write)

            if hasRead && hasWrite {
                return O_RDWR
            } else if hasWrite {
                return O_WRONLY
            } else {
                return O_RDONLY
            }
        }
    }

#endif

// MARK: - Windows Conversion

#if os(Windows)

    @preconcurrency public import WinSDK

    extension Kernel.Memory.Shared.Access {
        /// Converts access mode to Windows page protection flags.
        @usableFromInline
        internal var windowsPageProtection: DWORD {
            let hasWrite = contains(.write)
            return hasWrite ? DWORD(PAGE_READWRITE) : DWORD(PAGE_READONLY)
        }

        /// Converts access mode to Windows file map access flags.
        @usableFromInline
        internal var windowsMapAccess: DWORD {
            let hasWrite = contains(.write)
            // FILE_MAP_ALL_ACCESS = 0xF001F (SECTION_ALL_ACCESS)
            return hasWrite ? DWORD(0xF001F) : DWORD(FILE_MAP_READ)
        }
    }

#endif
