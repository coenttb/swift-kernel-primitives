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

// Platform imports for errno / GetLastError
#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

#if os(Windows)
    public import WinSDK
#endif

extension Kernel.Error {
    /// Unified platform error code (errno / Win32 last-error).
    ///
    /// Data-only: used as associated data in error enums.
    /// Use `.posix` or `.win32` accessors to extract typed values.
    ///
    /// ## Design Principles
    /// - **Capture once**: Raw platform code captured at syscall boundary, never re-derived.
    /// - **No loss of information**: Windows codes remain `UInt32`-accurate end-to-end.
    /// - **Data-only**: Not `Swift.Error`; prevents accidental "throw raw code".
    public enum Code: Sendable, Equatable, Hashable {
        /// POSIX errno value.
        case posix(Int32)

        /// Windows GetLastError value.
        case win32(UInt32)
    }
}

// MARK: - Capture Helpers (package, platform-gated)

extension Kernel.Error.Code {
    #if !os(Windows)
        /// Captures current errno (POSIX only).
        ///
        /// Must be called immediately after a failing syscall, before any other libc call.
//        @usableFromInline
        public static func captureErrno() -> Self {
            .posix(errno)
        }
    #endif

    #if os(Windows)
        /// Captures current GetLastError (Windows only).
        ///
        /// Must be called immediately after a failing syscall.
//        @usableFromInline
        public static func captureLastError() -> Self {
            .win32(UInt32(GetLastError()))
        }
    #endif
}

// MARK: - Typed Accessors

extension Kernel.Error.Code {
    /// The POSIX errno value, if this is a POSIX error.
    @inlinable
    public var posix: Int32? {
        if case .posix(let v) = self { v } else { nil }
    }

    /// The Win32 error code, if this is a Windows error.
    @inlinable
    public var win32: UInt32? {
        if case .win32(let v) = self { v } else { nil }
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Error.Code: CustomStringConvertible {
    public var description: String {
        switch self {
        case .posix(let code):
            return "posix(\(code))"
        case .win32(let code):
            return "win32(\(code))"
        }
    }
}
