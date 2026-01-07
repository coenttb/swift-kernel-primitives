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

// MARK: - Layer 0: Zero-Allocation Path Primitives
//
// This file contains only pointer-level operations suitable for embedded contexts.
// String conversion methods are in the Kernel module (Layer 1).

extension Kernel {
    /// A lifetime-safe, borrow-only path wrapper for syscall use.
    ///
    /// `Kernel.Path` is a thin wrapper over a null-terminated platform string pointer.
    /// It enforces lifetime safety through closure-based scoping:
    /// - The pointer storage is internal
    /// - All access is through scoped closures that prevent escape
    /// - The type is `~Copyable` to prevent implicit duplication
    ///
    /// ## Platform Notes
    ///
    /// - On POSIX: Uses narrow strings (`CChar`/UTF-8)
    /// - On Windows: Uses wide strings (`UInt16`/UTF-16)
    ///
    /// ## Layer 0 (Primitives) vs Layer 1 (Kernel)
    ///
    /// This type lives in Layer 0 (zero-allocation). For String convenience methods
    /// that allocate, see the extensions in the Kernel module.
    ///
    /// - Warning: This type is intentionally NOT `Sendable`. Pointer lifetimes
    ///   cannot be safely transferred across concurrency boundaries.
    public struct Path: ~Copyable {
        /// Internal storage for the null-terminated platform string.
        @usableFromInline
        internal let _cString: UnsafePointer<Char>
    }
}

// MARK: - Platform Character Type

extension Kernel.Path {
    /// Platform-native path character type.
    ///
    /// - POSIX (macOS, Linux): `CChar` (Int8, UTF-8)
    /// - Windows: `UInt16` (UTF-16)
    #if os(Windows)
        public typealias Char = UInt16
    #else
        public typealias Char = CChar
    #endif
}

// MARK: - Initialization

extension Kernel.Path {
    /// Creates a path from a platform string pointer.
    ///
    /// - Parameter cString: A pointer to a null-terminated platform string.
    ///
    /// - Warning: No validation is performed. The caller must ensure:
    ///   - The string is properly null-terminated
    ///   - The pointer remains valid for the lifetime of this `Path`
    ///   - The string does not contain interior NUL bytes
    @inlinable
    public init(unsafeCString cString: UnsafePointer<Char>) {
        self._cString = cString
    }
}

// MARK: - Scoped Pointer Access

extension Kernel.Path {
    /// Executes a closure with the underlying C string pointer.
    ///
    /// This is the safe way to access the raw pointer when needed for
    /// direct syscall interop.
    ///
    /// - Parameter body: A closure receiving the pointer.
    /// - Returns: The value returned by the closure.
    @inlinable
    public borrowing func withUnsafeCString<R: ~Copyable, E: Swift.Error>(
        _ body: (UnsafePointer<Char>) throws(E) -> R
    ) throws(E) -> R {
        try body(_cString)
    }

    /// The underlying C string pointer.
    ///
    /// - Warning: This defeats the lifetime safety model. The pointer is only
    ///   valid for the lifetime of this `Path` instance. Storing or returning
    ///   this pointer can lead to use-after-free bugs.
    ///
    /// Prefer `withUnsafeCString` for scoped access.
    @inlinable
    public var unsafeCString: UnsafePointer<Char> {
        _cString
    }
}

// MARK: - Conversion Errors

extension Kernel.Path {
    /// Errors that can occur during path string conversion.
    public enum ConversionError: Swift.Error, Sendable, Equatable {
        /// The string contains an interior NUL byte, which would truncate the path.
        case interiorNUL
    }
}
