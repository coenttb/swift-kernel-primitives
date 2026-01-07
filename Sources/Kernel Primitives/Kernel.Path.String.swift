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

// MARK: - Layer 1: String Convenience (Allocates)
//
// These methods convert Swift Strings to Kernel.Path instances.
// They allocate heap buffers and are NOT suitable for strict embedded contexts.
// For Layer 0 (zero-allocation), use the pointer-based initializers in Kernel Primitives.
//
// Note: Parameter packs cannot express `repeat Kernel.Path` because pack expansions
// require a type that references `each S`. Since `Kernel.Path` is a fixed type,
// we provide fixed-arity overloads for the common cases (1, 2, and 3 paths).

public import Kernel_Primitives

// MARK: - String Namespace

extension Kernel.Path {
    /// Namespace for string-to-path conversion operations.
    public enum String {
        /// Namespace for conversion operations.
        public enum Conversion {
            /// Errors that can occur during string-to-path conversion.
            public enum Error: Swift.Error, Sendable, Equatable {
                /// The string contains an interior NUL byte at the given index.
                ///
                /// Paths must not contain NUL bytes except as the terminator. An interior
                /// NUL would cause the path to be silently truncated when passed to syscalls.
                ///
                /// - Parameter index: For multi-path operations, indicates which argument
                ///   (0-based) contained the interior NUL. For single-path operations, always 0.
                case interiorNUL(index: Int)
            }
        }

        /// Typed error wrapper for string-to-path operations.
        ///
        /// This error type composes conversion failures with body failures,
        /// enabling 100% typed throws without existentials.
        ///
        /// ## Design
        /// - Conversion errors (interior NUL, encoding issues) are wrapped in `.conversion`.
        /// - Body errors are wrapped in `.body(E)`.
        /// - This is the only place where both failure domains exist in the public API.
        public enum Error<Body: Swift.Error>: Swift.Error {
            /// String-to-path conversion failed.
            case conversion(Conversion.Error)

            /// The body closure threw an error.
            case body(Body)
        }
    }
}

// MARK: - Error Conveniences

extension Kernel.Path.String.Error: Sendable where Body: Sendable {}

extension Kernel.Path.String.Error: Equatable where Body: Equatable {}

extension Kernel.Path.String.Error {
    /// Returns the body error if this is a `.body` case, otherwise `nil`.
    @inlinable
    public var body: Body? {
        if case .body(let e) = self { return e }
        return nil
    }

    /// Returns the conversion error if this is a `.conversion` case, otherwise `nil`.
    @inlinable
    public var conversion: Kernel.Path.String.Conversion.Error? {
        if case .conversion(let e) = self { return e }
        return nil
    }

    /// Maps the body case to a different error type.
    ///
    /// The `.conversion` case is preserved as-is.
    @inlinable
    public func mapBody<NewBody: Swift.Error>(
        _ transform: (Body) -> NewBody
    ) -> Kernel.Path.String.Error<NewBody> {
        switch self {
        case .conversion(let e): return .conversion(e)
        case .body(let e): return .body(transform(e))
        }
    }
}

// MARK: - Public Entrypoints

extension Kernel.Path {
    /// Executes a closure with a scoped path converted from a String.
    ///
    /// The path is valid only for the duration of the closure and cannot escape.
    /// This is the recommended way to use paths with Kernel syscalls.
    ///
    /// - Parameters:
    ///   - string: The path string (UTF-8 on POSIX, UTF-16 on Windows).
    ///   - body: A closure that receives the scoped path.
    /// - Returns: The value returned by the closure.
    /// - Throws: `String.Error.conversion` if the string contains NUL bytes,
    ///   or `String.Error.body` wrapping the error from the closure.
    ///
    /// ```swift
    /// let fd = try Kernel.Path.scope("/tmp/file.txt") { path in
    ///     try Kernel.File.Open.open(path: path, mode: .read, options: [], permissions: 0)
    /// }
    /// ```
    @inlinable
    public static func scope<S: StringProtocol, E: Swift.Error, R: ~Copyable>(
        _ string: S,
        _ body: (borrowing Kernel.Path) throws(E) -> R
    ) throws(String.Error<E>) -> R {
        try String.scope(string, body)
    }

    /// Executes a closure with a scoped path (non-throwing body).
    @inlinable
    public static func scope<S: StringProtocol, R: ~Copyable>(
        _ string: S,
        _ body: (borrowing Kernel.Path) -> R
    ) throws(String.Conversion.Error) -> R {
        try String.scope(string, body)
    }

    /// Executes a closure with two scoped paths converted from Strings.
    ///
    /// ```swift
    /// try Kernel.Path.scope("/src", "/dst") { src, dst in
    ///     try Kernel.File.Clone.clone(from: src, to: dst, behavior: .copyOnly)
    /// }
    /// ```
    @inlinable
    public static func scope<S1: StringProtocol, S2: StringProtocol, E: Swift.Error, R: ~Copyable>(
        _ string1: S1,
        _ string2: S2,
        _ body: (borrowing Kernel.Path, borrowing Kernel.Path) throws(E) -> R
    ) throws(String.Error<E>) -> R {
        try String.scope(string1, string2, body)
    }

    /// Executes a closure with two scoped paths (non-throwing body).
    @inlinable
    public static func scope<S1: StringProtocol, S2: StringProtocol, R: ~Copyable>(
        _ string1: S1,
        _ string2: S2,
        _ body: (borrowing Kernel.Path, borrowing Kernel.Path) -> R
    ) throws(String.Conversion.Error) -> R {
        try String.scope(string1, string2, body)
    }

    /// Executes a closure with three scoped paths converted from Strings.
    @inlinable
    public static func scope<S1: StringProtocol, S2: StringProtocol, S3: StringProtocol, E: Swift.Error, R: ~Copyable>(
        _ string1: S1,
        _ string2: S2,
        _ string3: S3,
        _ body: (borrowing Kernel.Path, borrowing Kernel.Path, borrowing Kernel.Path) throws(E) -> R
    ) throws(String.Error<E>) -> R {
        try String.scope(string1, string2, string3, body)
    }

    /// Executes a closure with three scoped paths (non-throwing body).
    @inlinable
    public static func scope<S1: StringProtocol, S2: StringProtocol, S3: StringProtocol, R: ~Copyable>(
        _ string1: S1,
        _ string2: S2,
        _ string3: S3,
        _ body: (borrowing Kernel.Path, borrowing Kernel.Path, borrowing Kernel.Path) -> R
    ) throws(String.Conversion.Error) -> R {
        try String.scope(string1, string2, string3, body)
    }
}

// MARK: - Single Path (Implementation)

extension Kernel.Path.String {
    @inlinable
    internal static func scope<S: StringProtocol, E: Swift.Error, R: ~Copyable>(
        _ string: S,
        _ body: (borrowing Kernel.Path) throws(E) -> R
    ) throws(Error<E>) -> R {
        #if os(Windows)
            let buffer: UnsafeMutablePointer<UInt16>
            do {
                buffer = try _allocateUTF16Buffer(string, index: 0)
            } catch {
                throw .conversion(error)
            }
            defer { buffer.deallocate() }
            do {
                return try body(Kernel.Path(unsafeCString: buffer))
            } catch {
                throw .body(error)
            }
        #else
            let buffer: UnsafeMutablePointer<CChar>
            do {
                buffer = try _allocateUTF8Buffer(string, index: 0)
            } catch {
                throw .conversion(error)
            }
            defer { buffer.deallocate() }
            do {
                return try body(Kernel.Path(unsafeCString: buffer))
            } catch {
                throw .body(error)
            }
        #endif
    }

    @inlinable
    internal static func scope<S: StringProtocol, R: ~Copyable>(
        _ string: S,
        _ body: (borrowing Kernel.Path) -> R
    ) throws(Conversion.Error) -> R {
        #if os(Windows)
            let buffer = try _allocateUTF16Buffer(string, index: 0)
            defer { buffer.deallocate() }
            return body(Kernel.Path(unsafeCString: buffer))
        #else
            let buffer = try _allocateUTF8Buffer(string, index: 0)
            defer { buffer.deallocate() }
            return body(Kernel.Path(unsafeCString: buffer))
        #endif
    }
}

// MARK: - Two Paths (Implementation)

extension Kernel.Path.String {
    @inlinable
    internal static func scope<S1: StringProtocol, S2: StringProtocol, E: Swift.Error, R: ~Copyable>(
        _ string1: S1,
        _ string2: S2,
        _ body: (borrowing Kernel.Path, borrowing Kernel.Path) throws(E) -> R
    ) throws(Error<E>) -> R {
        #if os(Windows)
            let buffer1: UnsafeMutablePointer<UInt16>
            let buffer2: UnsafeMutablePointer<UInt16>
            do {
                buffer1 = try _allocateUTF16Buffer(string1, index: 0)
            } catch {
                throw .conversion(error)
            }
            defer { buffer1.deallocate() }
            do {
                buffer2 = try _allocateUTF16Buffer(string2, index: 1)
            } catch {
                throw .conversion(error)
            }
            defer { buffer2.deallocate() }
            do {
                return try body(
                    Kernel.Path(unsafeCString: buffer1),
                    Kernel.Path(unsafeCString: buffer2)
                )
            } catch {
                throw .body(error)
            }
        #else
            let buffer1: UnsafeMutablePointer<CChar>
            let buffer2: UnsafeMutablePointer<CChar>
            do {
                buffer1 = try _allocateUTF8Buffer(string1, index: 0)
            } catch {
                throw .conversion(error)
            }
            defer { buffer1.deallocate() }
            do {
                buffer2 = try _allocateUTF8Buffer(string2, index: 1)
            } catch {
                throw .conversion(error)
            }
            defer { buffer2.deallocate() }
            do {
                return try body(
                    Kernel.Path(unsafeCString: buffer1),
                    Kernel.Path(unsafeCString: buffer2)
                )
            } catch {
                throw .body(error)
            }
        #endif
    }

    @inlinable
    internal static func scope<S1: StringProtocol, S2: StringProtocol, R: ~Copyable>(
        _ string1: S1,
        _ string2: S2,
        _ body: (borrowing Kernel.Path, borrowing Kernel.Path) -> R
    ) throws(Conversion.Error) -> R {
        #if os(Windows)
            let buffer1 = try _allocateUTF16Buffer(string1, index: 0)
            defer { buffer1.deallocate() }
            let buffer2 = try _allocateUTF16Buffer(string2, index: 1)
            defer { buffer2.deallocate() }
            return body(
                Kernel.Path(unsafeCString: buffer1),
                Kernel.Path(unsafeCString: buffer2)
            )
        #else
            let buffer1 = try _allocateUTF8Buffer(string1, index: 0)
            defer { buffer1.deallocate() }
            let buffer2 = try _allocateUTF8Buffer(string2, index: 1)
            defer { buffer2.deallocate() }
            return body(
                Kernel.Path(unsafeCString: buffer1),
                Kernel.Path(unsafeCString: buffer2)
            )
        #endif
    }
}

// MARK: - Three Paths (Implementation)

extension Kernel.Path.String {
    @inlinable
    internal static func scope<S1: StringProtocol, S2: StringProtocol, S3: StringProtocol, E: Swift.Error, R: ~Copyable>(
        _ string1: S1,
        _ string2: S2,
        _ string3: S3,
        _ body: (borrowing Kernel.Path, borrowing Kernel.Path, borrowing Kernel.Path) throws(E) -> R
    ) throws(Error<E>) -> R {
        #if os(Windows)
            let buffer1: UnsafeMutablePointer<UInt16>
            let buffer2: UnsafeMutablePointer<UInt16>
            let buffer3: UnsafeMutablePointer<UInt16>
            do {
                buffer1 = try _allocateUTF16Buffer(string1, index: 0)
            } catch {
                throw .conversion(error)
            }
            defer { buffer1.deallocate() }
            do {
                buffer2 = try _allocateUTF16Buffer(string2, index: 1)
            } catch {
                throw .conversion(error)
            }
            defer { buffer2.deallocate() }
            do {
                buffer3 = try _allocateUTF16Buffer(string3, index: 2)
            } catch {
                throw .conversion(error)
            }
            defer { buffer3.deallocate() }
            do {
                return try body(
                    Kernel.Path(unsafeCString: buffer1),
                    Kernel.Path(unsafeCString: buffer2),
                    Kernel.Path(unsafeCString: buffer3)
                )
            } catch {
                throw .body(error)
            }
        #else
            let buffer1: UnsafeMutablePointer<CChar>
            let buffer2: UnsafeMutablePointer<CChar>
            let buffer3: UnsafeMutablePointer<CChar>
            do {
                buffer1 = try _allocateUTF8Buffer(string1, index: 0)
            } catch {
                throw .conversion(error)
            }
            defer { buffer1.deallocate() }
            do {
                buffer2 = try _allocateUTF8Buffer(string2, index: 1)
            } catch {
                throw .conversion(error)
            }
            defer { buffer2.deallocate() }
            do {
                buffer3 = try _allocateUTF8Buffer(string3, index: 2)
            } catch {
                throw .conversion(error)
            }
            defer { buffer3.deallocate() }
            do {
                return try body(
                    Kernel.Path(unsafeCString: buffer1),
                    Kernel.Path(unsafeCString: buffer2),
                    Kernel.Path(unsafeCString: buffer3)
                )
            } catch {
                throw .body(error)
            }
        #endif
    }

    @inlinable
    internal static func scope<S1: StringProtocol, S2: StringProtocol, S3: StringProtocol, R: ~Copyable>(
        _ string1: S1,
        _ string2: S2,
        _ string3: S3,
        _ body: (borrowing Kernel.Path, borrowing Kernel.Path, borrowing Kernel.Path) -> R
    ) throws(Conversion.Error) -> R {
        #if os(Windows)
            let buffer1 = try _allocateUTF16Buffer(string1, index: 0)
            defer { buffer1.deallocate() }
            let buffer2 = try _allocateUTF16Buffer(string2, index: 1)
            defer { buffer2.deallocate() }
            let buffer3 = try _allocateUTF16Buffer(string3, index: 2)
            defer { buffer3.deallocate() }
            return body(
                Kernel.Path(unsafeCString: buffer1),
                Kernel.Path(unsafeCString: buffer2),
                Kernel.Path(unsafeCString: buffer3)
            )
        #else
            let buffer1 = try _allocateUTF8Buffer(string1, index: 0)
            defer { buffer1.deallocate() }
            let buffer2 = try _allocateUTF8Buffer(string2, index: 1)
            defer { buffer2.deallocate() }
            let buffer3 = try _allocateUTF8Buffer(string3, index: 2)
            defer { buffer3.deallocate() }
            return body(
                Kernel.Path(unsafeCString: buffer1),
                Kernel.Path(unsafeCString: buffer2),
                Kernel.Path(unsafeCString: buffer3)
            )
        #endif
    }
}

// MARK: - Buffer Allocation Helpers

#if os(Windows)
    @usableFromInline
    internal func _allocateUTF16Buffer<S: StringProtocol>(
        _ string: S,
        index: Int
    ) throws(Kernel.Path.String.Conversion.Error) -> UnsafeMutablePointer<UInt16> {
        let s = Swift.String(string)
        let utf16 = s.utf16

        // Check for interior NUL
        for unit in utf16 {
            if unit == 0 {
                throw .interiorNUL(index: index)
            }
        }

        let count = utf16.count + 1
        let buffer = UnsafeMutablePointer<UInt16>.allocate(capacity: count)
        var i = 0
        for unit in utf16 {
            buffer[i] = unit
            i += 1
        }
        buffer[i] = 0
        return buffer
    }
#else
    @usableFromInline
    internal func _allocateUTF8Buffer<S: StringProtocol>(
        _ string: S,
        index: Int
    ) throws(Kernel.Path.String.Conversion.Error) -> UnsafeMutablePointer<CChar> {
        let s = Swift.String(string)
        let utf8 = s.utf8

        // Check for interior NUL
        for byte in utf8 {
            if byte == 0 {
                throw .interiorNUL(index: index)
            }
        }

        let count = utf8.count + 1
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: count)
        var i = 0
        for byte in utf8 {
            buffer[i] = CChar(bitPattern: byte)
            i += 1
        }
        buffer[i] = 0
        return buffer
    }
#endif
