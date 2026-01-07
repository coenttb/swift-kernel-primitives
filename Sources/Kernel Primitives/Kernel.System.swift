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

public import Binary

extension Kernel {
    /// System information queries.
    public enum System {}
}

// MARK: - Alignment Helpers

extension Kernel.System {
    /// Rounds a file offset down to the nearest alignment boundary.
    ///
    /// - Parameters:
    ///   - offset: The offset to align.
    ///   - alignment: The alignment boundary (power of 2).
    /// - Returns: The largest aligned offset ≤ `offset`.
    @inlinable
    public static func alignDown(_ offset: Kernel.File.Offset, to alignment: Binary.Alignment) -> Kernel.File.Offset {
        alignment.alignDown(offset)
    }

    /// Rounds a file offset up to the nearest alignment boundary.
    ///
    /// - Parameters:
    ///   - offset: The offset to align.
    ///   - alignment: The alignment boundary (power of 2).
    /// - Returns: The smallest aligned offset ≥ `offset`.
    @inlinable
    public static func alignUp(_ offset: Kernel.File.Offset, to alignment: Binary.Alignment) -> Kernel.File.Offset {
        alignment.alignUp(offset)
    }

    /// Rounds a file size down to the nearest alignment boundary.
    ///
    /// - Parameters:
    ///   - size: The size to align.
    ///   - alignment: The alignment boundary (power of 2).
    /// - Returns: The largest aligned size ≤ `size`.
    @inlinable
    public static func alignDown(_ size: Kernel.File.Size, to alignment: Binary.Alignment) -> Kernel.File.Size {
        size.alignedDown(to: alignment)
    }

    /// Rounds a file size up to the nearest alignment boundary.
    ///
    /// - Parameters:
    ///   - size: The size to align.
    ///   - alignment: The alignment boundary (power of 2).
    /// - Returns: The smallest aligned size ≥ `size`.
    @inlinable
    public static func alignUp(_ size: Kernel.File.Size, to alignment: Binary.Alignment) -> Kernel.File.Size {
        size.alignedUp(to: alignment)
    }
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

    extension Kernel.System {
        /// Platform path length limit.
        ///
        /// Falls back to 4096 if the platform constant is undefined.
        /// Note: This is a conservative limit, not a universal truth.
        public static var pathMax: Kernel.System.Path.Length {
            #if canImport(Darwin)
                return Kernel.System.Path.Length(Int(PATH_MAX))  // 1024
            #else
                return Kernel.System.Path.Length(Int(PATH_MAX))  // Usually 4096
            #endif
        }

        /// Memory page size in bytes.
        ///
        /// This is the fundamental unit of memory management.
        /// Typically 4096 bytes on most systems, 16384 on Apple Silicon.
        public static var pageSize: Kernel.Memory.Page.Size {
            Kernel.Memory.Page.Size(Int(sysconf(Int32(_SC_PAGESIZE))))
        }

        /// Number of active/online processors.
        ///
        /// Uses `sysconf(_SC_NPROCESSORS_ONLN)` to get the count of
        /// processors currently online (not just configured).
        ///
        /// Returns 1 as a fallback if the syscall fails.
        public static var processorCount: Kernel.System.Processor.Count {
            let count = sysconf(Int32(_SC_NPROCESSORS_ONLN))
            return Kernel.System.Processor.Count(count > 0 ? Int(count) : 1)
        }

        /// Allocation granularity in bytes.
        ///
        /// On POSIX systems, this equals `pageSize`.
        /// On Windows, this is typically 64KB (larger than page size).
        ///
        /// Use this for memory mapping offset alignment.
        public static var allocationGranularity: Kernel.Memory.Allocation.Granularity {
            Kernel.Memory.Allocation.Granularity(Int(pageSize))
        }

        /// Sleeps for the specified number of nanoseconds.
        ///
        /// - Parameter nanoseconds: The number of nanoseconds to sleep.
        @inlinable
        public static func sleep(nanoseconds: UInt64) {
            var ts = timespec()
            ts.tv_sec = Int(nanoseconds / 1_000_000_000)
            ts.tv_nsec = Int(nanoseconds % 1_000_000_000)
            nanosleep(&ts, nil)
        }

        /// Sleeps for the specified duration.
        ///
        /// - Parameter duration: The duration to sleep.
        @inlinable
        public static func sleep(_ duration: Duration) {
            let (seconds, attoseconds) = duration.components
            var ts = timespec()
            ts.tv_sec = Int(seconds)
            ts.tv_nsec = Int(attoseconds / 1_000_000_000)
            nanosleep(&ts, nil)
        }
    }
#endif

#if os(Windows)
    @preconcurrency public import WinSDK

    // PATTERN EXCEPTION: Global immutable cache (Rule 6.6)
    //
    // Justification: This is an immutable cache of system configuration that:
    // - Never changes at runtime (hardware properties)
    // - Is initialized exactly once on first access
    // - Has no observable side effects
    // - Cannot be testably injected (GetSystemInfo is a syscall)
    //
    // Uses nonisolated(unsafe) because SYSTEM_INFO is not Sendable but is
    // immutable after initialization. The value is a `let` constant.
    private nonisolated(unsafe) let cachedSystemInfo: SYSTEM_INFO = {
        var info = SYSTEM_INFO()
        GetSystemInfo(&info)
        return info
    }()

    extension Kernel.System {
        /// Platform path length limit.
        ///
        /// Note: This is a conservative limit. Extended-length paths
        /// on Windows can exceed MAX_PATH using \\?\ prefix.
        public static var pathMax: Kernel.System.Path.Length {
            Kernel.System.Path.Length(Int(MAX_PATH))  // 260
        }

        /// Memory page size in bytes.
        public static var pageSize: Kernel.Memory.Page.Size {
            Kernel.Memory.Page.Size(Int(cachedSystemInfo.dwPageSize))
        }

        /// Allocation granularity in bytes.
        ///
        /// On Windows, this is typically 64KB and differs from page size.
        /// Memory mapping offsets must be aligned to this value.
        public static var allocationGranularity: Kernel.Memory.Allocation.Granularity {
            Kernel.Memory.Allocation.Granularity(Int(cachedSystemInfo.dwAllocationGranularity))
        }

        /// Number of active processors.
        ///
        /// Uses the cached `SYSTEM_INFO` from `GetSystemInfo`.
        public static var processorCount: Kernel.System.Processor.Count {
            Kernel.System.Processor.Count(Int(cachedSystemInfo.dwNumberOfProcessors))
        }

        /// Sleeps for the specified number of nanoseconds.
        ///
        /// - Parameter nanoseconds: The number of nanoseconds to sleep.
        /// - Note: Windows Sleep has millisecond granularity.
        public static func sleep(nanoseconds: UInt64) {
            let milliseconds = nanoseconds / 1_000_000
            Sleep(DWORD(min(milliseconds, UInt64(DWORD.max))))
        }

        /// Sleeps for the specified duration.
        ///
        /// - Parameter duration: The duration to sleep.
        /// - Note: Windows Sleep has millisecond granularity.
        public static func sleep(_ duration: Duration) {
            let (seconds, attoseconds) = duration.components
            let totalMs = UInt64(seconds) * 1000 + UInt64(attoseconds / 1_000_000_000_000_000)
            Sleep(DWORD(min(totalMs, UInt64(DWORD.max))))
        }
    }
#endif
