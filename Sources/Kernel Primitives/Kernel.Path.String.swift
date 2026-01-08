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
// ## Platform String Representation
//
// - **POSIX (macOS, Linux, BSD):** Paths are null-terminated UTF-8 (`CChar*`).
//   The kernel treats paths as opaque byte sequences; UTF-8 is convention.
//
// - **Windows:** Paths are null-terminated UTF-16LE (`UInt16*`, aka `LPCWSTR`).
//   Windows APIs use "wide" (W-suffix) functions that expect UTF-16.
//
// The abstraction point is `Kernel.Path.Char`:
// - `CChar` on POSIX
// - `UInt16` on Windows
//
// Note: Parameter packs cannot express `repeat Kernel.Path` because pack expansions
// require a type that references `each S`. Since `Kernel.Path` is a fixed type,
// we provide fixed-arity overloads for the common cases (1, 2, and 3 paths).

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

// MARK: - Scope Accessor

extension Kernel.Path {
    /// Nested accessor for scoped string-to-path conversions.
    ///
    /// Operations use nested accessors for path and array handling:
    ///
    /// ```swift
    /// // Single path
    /// try Kernel.Path.scope("/tmp/file.txt") { path in
    ///     try Kernel.File.Open.open(path: path, mode: .read)
    /// }
    ///
    /// // Two paths
    /// try Kernel.Path.scope("/src", "/dst") { src, dst in
    ///     try Kernel.File.Clone.clone(from: src, to: dst)
    /// }
    ///
    /// // String arrays (for argv/envp)
    /// try Kernel.Path.scope.array(["/bin/sh", "-c", "echo hello"]) { argv in
    ///     // argv is UnsafePointer<UnsafePointer<Kernel.Path.Char>?> (NULL-terminated)
    /// }
    /// ```
    @inlinable
    public static var scope: String.Scope { String.Scope() }
}

// MARK: - Scope Type

extension Kernel.Path.String {
    /// Namespace for scoped string-to-path operations.
    public struct Scope {
        @inlinable
        public init() {}
    }
}

// MARK: - Single Path

extension Kernel.Path.String.Scope {
    /// Executes a closure with a scoped path converted from a String.
    ///
    /// The path is valid only for the duration of the closure and cannot escape.
    ///
    /// - Parameters:
    ///   - string: The path string (UTF-8 on POSIX, UTF-16 on Windows).
    ///   - body: A closure that receives the scoped path.
    /// - Returns: The value returned by the closure.
    /// - Throws: `String.Error.conversion` if the string contains NUL bytes,
    ///   or `String.Error.body` wrapping the error from the closure.
    @_disfavoredOverload
    @inlinable
    public func callAsFunction<S: StringProtocol, E: Swift.Error, R: ~Copyable>(
        _ string: S,
        _ body: (borrowing Kernel.Path) throws(E) -> R
    ) throws(Kernel.Path.String.Error<E>) -> R {
        let buffer: UnsafeMutablePointer<Kernel.Path.Char>
        do {
            buffer = try _allocateBuffer(string, index: 0)
        } catch {
            throw .conversion(error)
        }
        defer { buffer.deallocate() }
        do {
            return try body(Kernel.Path(unsafeCString: buffer))
        } catch {
            throw .body(error)
        }
    }

    /// Pass-through overload: when body already throws our wrapper type, rethrow directly.
    ///
    /// This prevents nested wrappers like `Error<Error<E>>` when scopes are composed.
    /// Overload resolution selects this when the body's throw type is `Kernel.Path.String.Error<E>`.
    @inlinable
    public func callAsFunction<S: StringProtocol, NestedBody: Swift.Error, R: ~Copyable>(
        _ string: S,
        _ body: (borrowing Kernel.Path) throws(Kernel.Path.String.Error<NestedBody>) -> R
    ) throws(Kernel.Path.String.Error<NestedBody>) -> R {
        let buffer: UnsafeMutablePointer<Kernel.Path.Char>
        do {
            buffer = try _allocateBuffer(string, index: 0)
        } catch {
            throw .conversion(error)
        }
        defer { buffer.deallocate() }
        return try body(Kernel.Path(unsafeCString: buffer))
    }

    /// Executes a closure with a scoped path (non-throwing body).
    @inlinable
    public func callAsFunction<S: StringProtocol, R: ~Copyable>(
        _ string: S,
        _ body: (borrowing Kernel.Path) -> R
    ) throws(Kernel.Path.String.Conversion.Error) -> R {
        let buffer = try _allocateBuffer(string, index: 0)
        defer { buffer.deallocate() }
        return body(Kernel.Path(unsafeCString: buffer))
    }
}

// MARK: - Two Paths

extension Kernel.Path.String.Scope {
    /// Executes a closure with two scoped paths converted from Strings.
    @inlinable
    public func callAsFunction<S1: StringProtocol, S2: StringProtocol, E: Swift.Error, R: ~Copyable>(
        _ string1: S1,
        _ string2: S2,
        _ body: (borrowing Kernel.Path, borrowing Kernel.Path) throws(E) -> R
    ) throws(Kernel.Path.String.Error<E>) -> R {
        let buffer1: UnsafeMutablePointer<Kernel.Path.Char>
        let buffer2: UnsafeMutablePointer<Kernel.Path.Char>
        do {
            buffer1 = try _allocateBuffer(string1, index: 0)
        } catch {
            throw .conversion(error)
        }
        defer { buffer1.deallocate() }
        do {
            buffer2 = try _allocateBuffer(string2, index: 1)
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
    }

    /// Executes a closure with two scoped paths (non-throwing body).
    @inlinable
    public func callAsFunction<S1: StringProtocol, S2: StringProtocol, R: ~Copyable>(
        _ string1: S1,
        _ string2: S2,
        _ body: (borrowing Kernel.Path, borrowing Kernel.Path) -> R
    ) throws(Kernel.Path.String.Conversion.Error) -> R {
        let buffer1 = try _allocateBuffer(string1, index: 0)
        defer { buffer1.deallocate() }
        let buffer2 = try _allocateBuffer(string2, index: 1)
        defer { buffer2.deallocate() }
        return body(
            Kernel.Path(unsafeCString: buffer1),
            Kernel.Path(unsafeCString: buffer2)
        )
    }
}

// MARK: - Three Paths

extension Kernel.Path.String.Scope {
    /// Executes a closure with three scoped paths converted from Strings.
    @inlinable
    public func callAsFunction<S1: StringProtocol, S2: StringProtocol, S3: StringProtocol, E: Swift.Error, R: ~Copyable>(
        _ string1: S1,
        _ string2: S2,
        _ string3: S3,
        _ body: (borrowing Kernel.Path, borrowing Kernel.Path, borrowing Kernel.Path) throws(E) -> R
    ) throws(Kernel.Path.String.Error<E>) -> R {
        let buffer1: UnsafeMutablePointer<Kernel.Path.Char>
        let buffer2: UnsafeMutablePointer<Kernel.Path.Char>
        let buffer3: UnsafeMutablePointer<Kernel.Path.Char>
        do {
            buffer1 = try _allocateBuffer(string1, index: 0)
        } catch {
            throw .conversion(error)
        }
        defer { buffer1.deallocate() }
        do {
            buffer2 = try _allocateBuffer(string2, index: 1)
        } catch {
            throw .conversion(error)
        }
        defer { buffer2.deallocate() }
        do {
            buffer3 = try _allocateBuffer(string3, index: 2)
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
    }

    /// Executes a closure with three scoped paths (non-throwing body).
    @inlinable
    public func callAsFunction<S1: StringProtocol, S2: StringProtocol, S3: StringProtocol, R: ~Copyable>(
        _ string1: S1,
        _ string2: S2,
        _ string3: S3,
        _ body: (borrowing Kernel.Path, borrowing Kernel.Path, borrowing Kernel.Path) -> R
    ) throws(Kernel.Path.String.Conversion.Error) -> R {
        let buffer1 = try _allocateBuffer(string1, index: 0)
        defer { buffer1.deallocate() }
        let buffer2 = try _allocateBuffer(string2, index: 1)
        defer { buffer2.deallocate() }
        let buffer3 = try _allocateBuffer(string3, index: 2)
        defer { buffer3.deallocate() }
        return body(
            Kernel.Path(unsafeCString: buffer1),
            Kernel.Path(unsafeCString: buffer2),
            Kernel.Path(unsafeCString: buffer3)
        )
    }
}

// MARK: - Array Accessor

extension Kernel.Path.String.Scope {
    /// Nested accessor for string array operations.
    ///
    /// Converts string arrays to NULL-terminated platform string arrays:
    /// - **POSIX:** UTF-8 (`CChar*`), suitable for exec* and posix_spawn
    /// - **Windows:** UTF-16 (`UInt16*`), suitable for Windows APIs
    ///
    /// The closure receives `UnsafePointer<UnsafePointer<Kernel.Path.Char>?>`.
    @inlinable
    public var array: Array { Array() }
}

// MARK: - Array Type

extension Kernel.Path.String.Scope {
    /// Namespace for scoped string array operations.
    public struct Array {
        @inlinable
        public init() {}
    }
}

// MARK: - Single Array

extension Kernel.Path.String.Scope.Array {
    /// Executes a closure with a scoped NULL-terminated platform string array.
    ///
    /// Converts an array of Swift strings to a NULL-terminated array of platform strings:
    /// - **POSIX:** UTF-8 (`CChar*`), suitable for exec* and posix_spawn
    /// - **Windows:** UTF-16 (`UInt16*`), suitable for Windows APIs
    ///
    /// - Parameters:
    ///   - strings: The strings to convert.
    ///   - body: A closure that receives the NULL-terminated array pointer.
    /// - Returns: The value returned by the closure.
    /// - Throws: `String.Error.conversion` if any string contains NUL bytes,
    ///   or `String.Error.body` wrapping the error from the closure.
    ///
    /// ```swift
    /// let argv = ["/bin/echo", "hello", "world"]
    /// try Kernel.Path.scope.array(argv) { argvPtr in
    ///     // argvPtr is UnsafePointer<UnsafePointer<Kernel.Path.Char>?>
    ///     // argvPtr[0] -> "/bin/echo\0"
    ///     // argvPtr[1] -> "hello\0"
    ///     // argvPtr[2] -> "world\0"
    ///     // argvPtr[3] -> nil (NULL terminator)
    /// }
    /// ```
    ///
    /// - Note: On Windows, process creation typically uses `CreateProcessW` with a command
    ///   line string rather than an argv array. This API is useful for internal bridging
    ///   and APIs that accept `LPCWSTR*`.
    @_disfavoredOverload
    @inlinable
    public func callAsFunction<S: StringProtocol, E: Swift.Error, R: ~Copyable>(
        _ strings: [S],
        _ body: (UnsafePointer<UnsafePointer<Kernel.Path.Char>?>) throws(E) -> R
    ) throws(Kernel.Path.String.Error<E>) -> R {
        var buffers: [UnsafeMutablePointer<Kernel.Path.Char>] = []
        buffers.reserveCapacity(strings.count)
        defer { for buffer in buffers { buffer.deallocate() } }

        for (index, string) in strings.enumerated() {
            let buffer: UnsafeMutablePointer<Kernel.Path.Char>
            do {
                buffer = try _allocateBuffer(string, index: index)
            } catch {
                throw .conversion(error)
            }
            buffers.append(buffer)
        }

        let pointerArray = UnsafeMutablePointer<UnsafePointer<Kernel.Path.Char>?>.allocate(
            capacity: strings.count + 1
        )
        defer { pointerArray.deallocate() }

        for (index, buffer) in buffers.enumerated() {
            pointerArray[index] = UnsafePointer(buffer)
        }
        pointerArray[strings.count] = nil

        do {
            return try body(UnsafePointer(pointerArray))
        } catch {
            throw .body(error)
        }
    }

    /// Pass-through overload: when body already throws our wrapper type, rethrow directly.
    ///
    /// This prevents nested wrappers like `Error<Error<E>>` when scopes are composed.
    /// Overload resolution selects this when the body's throw type is `Kernel.Path.String.Error<E>`.
    @inlinable
    public func callAsFunction<S: StringProtocol, E: Swift.Error, R: ~Copyable>(
        _ strings: [S],
        _ body: (UnsafePointer<UnsafePointer<Kernel.Path.Char>?>) throws(Kernel.Path.String.Error<E>) -> R
    ) throws(Kernel.Path.String.Error<E>) -> R {
        var buffers: [UnsafeMutablePointer<Kernel.Path.Char>] = []
        buffers.reserveCapacity(strings.count)
        defer { for buffer in buffers { buffer.deallocate() } }

        for (index, string) in strings.enumerated() {
            let buffer: UnsafeMutablePointer<Kernel.Path.Char>
            do {
                buffer = try _allocateBuffer(string, index: index)
            } catch {
                throw .conversion(error)
            }
            buffers.append(buffer)
        }

        let pointerArray = UnsafeMutablePointer<UnsafePointer<Kernel.Path.Char>?>.allocate(
            capacity: strings.count + 1
        )
        defer { pointerArray.deallocate() }

        for (index, buffer) in buffers.enumerated() {
            pointerArray[index] = UnsafePointer(buffer)
        }
        pointerArray[strings.count] = nil

        return try body(UnsafePointer(pointerArray))
    }

    /// Executes a closure with a scoped NULL-terminated platform string array (non-throwing body).
    @inlinable
    public func callAsFunction<S: StringProtocol, R: ~Copyable>(
        _ strings: [S],
        _ body: (UnsafePointer<UnsafePointer<Kernel.Path.Char>?>) -> R
    ) throws(Kernel.Path.String.Conversion.Error) -> R {
        var buffers: [UnsafeMutablePointer<Kernel.Path.Char>] = []
        buffers.reserveCapacity(strings.count)
        defer { for buffer in buffers { buffer.deallocate() } }

        for (index, string) in strings.enumerated() {
            let buffer = try _allocateBuffer(string, index: index)
            buffers.append(buffer)
        }

        let pointerArray = UnsafeMutablePointer<UnsafePointer<Kernel.Path.Char>?>.allocate(
            capacity: strings.count + 1
        )
        defer { pointerArray.deallocate() }

        for (index, buffer) in buffers.enumerated() {
            pointerArray[index] = UnsafePointer(buffer)
        }
        pointerArray[strings.count] = nil

        return body(UnsafePointer(pointerArray))
    }
}

// MARK: - Two Arrays

extension Kernel.Path.String.Scope.Array {
    /// Executes a closure with two scoped NULL-terminated platform string arrays.
    ///
    /// Useful for posix_spawn which needs both argv and envp.
    ///
    /// ```swift
    /// let argv = ["/bin/sh", "-c", "echo $FOO"]
    /// let envp = ["FOO=bar"]
    /// try Kernel.Path.scope.array(argv, envp) { argvPtr, envpPtr in
    ///     // Both are NULL-terminated arrays of Kernel.Path.Char pointers
    /// }
    /// ```
    @_disfavoredOverload
    @inlinable
    public func callAsFunction<S1: StringProtocol, S2: StringProtocol, E: Swift.Error, R: ~Copyable>(
        _ strings1: [S1],
        _ strings2: [S2],
        _ body: (UnsafePointer<UnsafePointer<Kernel.Path.Char>?>, UnsafePointer<UnsafePointer<Kernel.Path.Char>?>) throws(E) -> R
    ) throws(Kernel.Path.String.Error<E>) -> R {
        var buffers1: [UnsafeMutablePointer<Kernel.Path.Char>] = []
        buffers1.reserveCapacity(strings1.count)
        defer { for buffer in buffers1 { buffer.deallocate() } }

        for (index, string) in strings1.enumerated() {
            let buffer: UnsafeMutablePointer<Kernel.Path.Char>
            do {
                buffer = try _allocateBuffer(string, index: index)
            } catch {
                throw .conversion(error)
            }
            buffers1.append(buffer)
        }

        var buffers2: [UnsafeMutablePointer<Kernel.Path.Char>] = []
        buffers2.reserveCapacity(strings2.count)
        defer { for buffer in buffers2 { buffer.deallocate() } }

        for (index, string) in strings2.enumerated() {
            let buffer: UnsafeMutablePointer<Kernel.Path.Char>
            do {
                buffer = try _allocateBuffer(string, index: strings1.count + index)
            } catch {
                throw .conversion(error)
            }
            buffers2.append(buffer)
        }

        let pointerArray1 = UnsafeMutablePointer<UnsafePointer<Kernel.Path.Char>?>.allocate(
            capacity: strings1.count + 1
        )
        defer { pointerArray1.deallocate() }

        let pointerArray2 = UnsafeMutablePointer<UnsafePointer<Kernel.Path.Char>?>.allocate(
            capacity: strings2.count + 1
        )
        defer { pointerArray2.deallocate() }

        for (index, buffer) in buffers1.enumerated() {
            pointerArray1[index] = UnsafePointer(buffer)
        }
        pointerArray1[strings1.count] = nil

        for (index, buffer) in buffers2.enumerated() {
            pointerArray2[index] = UnsafePointer(buffer)
        }
        pointerArray2[strings2.count] = nil

        do {
            return try body(UnsafePointer(pointerArray1), UnsafePointer(pointerArray2))
        } catch {
            throw .body(error)
        }
    }

    /// Pass-through overload: when body already throws our wrapper type, rethrow directly.
    ///
    /// This prevents nested wrappers like `Error<Error<E>>` when scopes are composed.
    /// Overload resolution selects this when the body's throw type is `Kernel.Path.String.Error<E>`.
    @inlinable
    public func callAsFunction<S1: StringProtocol, S2: StringProtocol, E: Swift.Error, R: ~Copyable>(
        _ strings1: [S1],
        _ strings2: [S2],
        _ body: (
            UnsafePointer<UnsafePointer<Kernel.Path.Char>?>,
            UnsafePointer<UnsafePointer<Kernel.Path.Char>?>
        ) throws(Kernel.Path.String.Error<E>) -> R
    ) throws(Kernel.Path.String.Error<E>) -> R {
        var buffers1: [UnsafeMutablePointer<Kernel.Path.Char>] = []
        buffers1.reserveCapacity(strings1.count)
        defer { for buffer in buffers1 { buffer.deallocate() } }

        for (index, string) in strings1.enumerated() {
            let buffer: UnsafeMutablePointer<Kernel.Path.Char>
            do {
                buffer = try _allocateBuffer(string, index: index)
            } catch {
                throw .conversion(error)
            }
            buffers1.append(buffer)
        }

        var buffers2: [UnsafeMutablePointer<Kernel.Path.Char>] = []
        buffers2.reserveCapacity(strings2.count)
        defer { for buffer in buffers2 { buffer.deallocate() } }

        for (index, string) in strings2.enumerated() {
            let buffer: UnsafeMutablePointer<Kernel.Path.Char>
            do {
                buffer = try _allocateBuffer(string, index: strings1.count + index)
            } catch {
                throw .conversion(error)
            }
            buffers2.append(buffer)
        }

        let pointerArray1 = UnsafeMutablePointer<UnsafePointer<Kernel.Path.Char>?>.allocate(
            capacity: strings1.count + 1
        )
        defer { pointerArray1.deallocate() }

        let pointerArray2 = UnsafeMutablePointer<UnsafePointer<Kernel.Path.Char>?>.allocate(
            capacity: strings2.count + 1
        )
        defer { pointerArray2.deallocate() }

        for (index, buffer) in buffers1.enumerated() {
            pointerArray1[index] = UnsafePointer(buffer)
        }
        pointerArray1[strings1.count] = nil

        for (index, buffer) in buffers2.enumerated() {
            pointerArray2[index] = UnsafePointer(buffer)
        }
        pointerArray2[strings2.count] = nil

        return try body(UnsafePointer(pointerArray1), UnsafePointer(pointerArray2))
    }

    /// Executes a closure with two scoped NULL-terminated platform string arrays (non-throwing body).
    @inlinable
    public func callAsFunction<S1: StringProtocol, S2: StringProtocol, R: ~Copyable>(
        _ strings1: [S1],
        _ strings2: [S2],
        _ body: (UnsafePointer<UnsafePointer<Kernel.Path.Char>?>, UnsafePointer<UnsafePointer<Kernel.Path.Char>?>) -> R
    ) throws(Kernel.Path.String.Conversion.Error) -> R {
        var buffers1: [UnsafeMutablePointer<Kernel.Path.Char>] = []
        buffers1.reserveCapacity(strings1.count)
        defer { for buffer in buffers1 { buffer.deallocate() } }

        for (index, string) in strings1.enumerated() {
            let buffer = try _allocateBuffer(string, index: index)
            buffers1.append(buffer)
        }

        var buffers2: [UnsafeMutablePointer<Kernel.Path.Char>] = []
        buffers2.reserveCapacity(strings2.count)
        defer { for buffer in buffers2 { buffer.deallocate() } }

        for (index, string) in strings2.enumerated() {
            let buffer = try _allocateBuffer(string, index: strings1.count + index)
            buffers2.append(buffer)
        }

        let pointerArray1 = UnsafeMutablePointer<UnsafePointer<Kernel.Path.Char>?>.allocate(
            capacity: strings1.count + 1
        )
        defer { pointerArray1.deallocate() }

        let pointerArray2 = UnsafeMutablePointer<UnsafePointer<Kernel.Path.Char>?>.allocate(
            capacity: strings2.count + 1
        )
        defer { pointerArray2.deallocate() }

        for (index, buffer) in buffers1.enumerated() {
            pointerArray1[index] = UnsafePointer(buffer)
        }
        pointerArray1[strings1.count] = nil

        for (index, buffer) in buffers2.enumerated() {
            pointerArray2[index] = UnsafePointer(buffer)
        }
        pointerArray2[strings2.count] = nil

        return body(UnsafePointer(pointerArray1), UnsafePointer(pointerArray2))
    }
}

// MARK: - Buffer Allocation Helper

/// Allocates a null-terminated platform string buffer from a Swift string.
///
/// - Parameters:
///   - string: The source string.
///   - index: Index for error reporting in multi-path operations.
/// - Returns: A newly allocated buffer containing the null-terminated string.
/// - Throws: `interiorNUL` if the string contains an embedded NUL character.
///
/// ## Platform Encoding
///
/// - **POSIX:** UTF-8 (`CChar` / `Int8`)
/// - **Windows:** UTF-16LE (`UInt16`)
@usableFromInline
internal func _allocateBuffer<S: StringProtocol>(
    _ string: S,
    index: Int
) throws(Kernel.Path.String.Conversion.Error) -> UnsafeMutablePointer<Kernel.Path.Char> {
    let s = Swift.String(string)
    #if os(Windows)
        let units = s.utf16
        for unit in units where unit == 0 {
            throw .interiorNUL(index: index)
        }
        let count = units.count + 1
        let buffer = UnsafeMutablePointer<Kernel.Path.Char>.allocate(capacity: count)
        var i = 0
        for unit in units {
            buffer[i] = unit
            i += 1
        }
        buffer[i] = 0
        return buffer
    #else
        let bytes = s.utf8
        for byte in bytes where byte == 0 {
            throw .interiorNUL(index: index)
        }
        let count = bytes.count + 1
        let buffer = UnsafeMutablePointer<Kernel.Path.Char>.allocate(capacity: count)
        var i = 0
        for byte in bytes {
            buffer[i] = Kernel.Path.Char(bitPattern: byte)
            i += 1
        }
        buffer[i] = 0
        return buffer
    #endif
}
