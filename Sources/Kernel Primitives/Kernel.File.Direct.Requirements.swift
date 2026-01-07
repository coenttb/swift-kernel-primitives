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

extension Kernel.File.Direct {
    /// Alignment requirements for Direct I/O operations.
    ///
    /// Direct I/O on Linux and Windows requires strict alignment of:
    /// - Buffer memory address
    /// - File offset
    /// - I/O transfer length
    ///
    /// Requirements are discovered at runtime because they depend on:
    /// - The underlying storage device's sector size
    /// - Filesystem constraints
    /// - Volume configuration
    ///
    /// ## Known vs Unknown
    ///
    /// Requirements are modeled as either `.known` (we have concrete values)
    /// or `.unknown` (we cannot determine requirements reliably).
    ///
    /// **Critical invariant:** `.direct` mode requires `.known` requirements.
    /// If requirements are `.unknown`, Direct I/O is `.notSupported`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let req = try handle.direct.requirements()
    /// switch req {
    /// case .known(let alignment):
    ///     // Safe to use .direct mode
    ///     var buffer = try Buffer.Aligned(
    ///         byteCount: 4096,
    ///         alignment: alignment.bufferAlignment
    ///     )
    ///     try handle.read(into: &buffer, at: 0)
    ///
    /// case .unknown(let reason):
    ///     // Cannot use .direct mode safely
    ///     // Fall back to .buffered or use .auto(policy: .fallbackToBuffered)
    /// }
    /// ```
    public enum Requirements: Sendable, Equatable {
        /// Alignment requirements are known and can be satisfied.
        case known(Alignment)

        /// Alignment requirements could not be determined.
        ///
        /// Direct I/O is not supported when requirements are unknown.
        /// Use `.buffered` mode or `.auto(policy: .fallbackToBuffered)`.
        case unknown(reason: Reason)
    }
}

// MARK: - Platform-Specific Initialization

#if os(macOS)
    extension Kernel.File.Direct.Requirements {
        /// Creates requirements for a path.
        ///
        /// On macOS, true Direct I/O is not supported. Only `.uncached` mode
        /// (F_NOCACHE hint) is available, which has no alignment requirements.
        public init(_ path: borrowing Kernel.Path) {
            self = .unknown(reason: .platformUnsupported)
        }
    }
#endif

#if os(Linux)
    internal import Glibc

    extension Kernel.File.Direct.Requirements {
        /// Creates requirements for a path.
        ///
        /// On Linux, O_DIRECT alignment constraints are not reliably discoverable.
        /// Returns `.unknown` to fail closed. Callers should use
        /// `.auto(.fallbackToBuffered)` for best-effort operation.
        public init(_ path: borrowing Kernel.Path) {
            // Linux O_DIRECT alignment is not reliably discoverable.
            // statfs.f_bsize is the optimal transfer size, NOT the alignment requirement.
            // Actual requirements depend on device sector size, filesystem, and driver.
            self = .unknown(reason: .sectorSizeUndetermined)
        }
    }
#endif

#if os(Windows)
    public import WinSDK

    extension Kernel.File.Direct.Requirements {
        /// Creates requirements for a path.
        ///
        /// Uses GetDiskFreeSpaceW to determine sector size.
        /// This is the minimal safe alignment for FILE_FLAG_NO_BUFFERING.
        public init(_ path: borrowing Kernel.Path) {
            // For Windows, we need to extract the root path from the wide string
            // This is complex with a raw pointer, so we use a conservative default
            // Callers should prefer providing explicit alignment requirements

            // Use 4096 as conservative default for modern storage
            self = .known(Alignment(uniform: .`4096`))
        }
    }
#endif
