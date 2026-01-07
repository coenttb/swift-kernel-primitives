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

extension Kernel {
    /// Syscall result normalization utilities.
    public enum Syscall {}
}

// MARK: - Rule Type

extension Kernel.Syscall {
    /// A predicate for validating syscall results.
    ///
    /// Rules are composable values that encode success conditions.
    /// Use static members like `.nonNegative` or `.equals(0)` at call sites.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let fd = try Kernel.Syscall.require(
    ///     open(path, flags),
    ///     .nonNegative,
    ///     orThrow: Error.current()
    /// )
    /// ```
    public struct Rule<T>: Sendable {
        @usableFromInline
        internal let check: @Sendable (T) -> Bool

        @inlinable
        public init(_ check: @escaping @Sendable (T) -> Bool) {
            self.check = check
        }
    }
}

// MARK: - The Single Primitive

extension Kernel.Syscall {
    /// Validates a syscall result against a rule, throwing on failure.
    ///
    /// This is the single normalization primitive. All sentinel semantics are
    /// expressed through the `rule` parameter, keeping the API composable
    /// and avoiding compound function names.
    ///
    /// The error is constructed only on the failure path via `@autoclosure`,
    /// ensuring that error capture (e.g., `errno`) happens immediately when needed.
    ///
    /// - Parameters:
    ///   - value: The syscall return value.
    ///   - rule: A rule that returns `true` if the value indicates success.
    ///   - makeError: Error to throw on failure (evaluated only on failure path).
    /// - Returns: The value if the rule passes.
    /// - Throws: The error from `makeError` if the rule fails.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Non-negative integer result (read, write, open)
    /// let bytes = try Kernel.Syscall.require(
    ///     read(fd, buffer, count),
    ///     .nonNegative,
    ///     orThrow: Error.current()
    /// )
    ///
    /// // Exact match (close, munmap)
    /// try Kernel.Syscall.require(
    ///     close(fd),
    ///     .equals(0),
    ///     orThrow: Error.current()
    /// )
    ///
    /// // Pointer sentinel (mmap)
    /// let ptr = try Kernel.Syscall.require(
    ///     mmap(...),
    ///     .not(MAP_FAILED),
    ///     orThrow: Error.current()
    /// )
    /// ```
    @discardableResult
    @inlinable
    public static func require<E: Swift.Error, T>(
        _ value: T,
        _ rule: Rule<T>,
        orThrow makeError: @autoclosure () -> E
    ) throws(E) -> T {
        guard rule.check(value) else { throw makeError() }
        return value
    }
}

// MARK: - Integer Rules

extension Kernel.Syscall.Rule where T == Int {
    /// POSIX: result >= 0 means success (read, write, open, etc.)
    ///
    /// Use for syscalls that return:
    /// - A non-negative value on success (e.g., byte count, file descriptor)
    /// - -1 on failure with errno set
    public static var nonNegative: Self { .init { $0 >= 0 } }
}

// NOTE: No Int32.nonNegative — Int32 syscalls typically use 0 == success.
// Use .equals(0) for those cases.

// MARK: - Equatable Rules

extension Kernel.Syscall.Rule where T: Equatable & Sendable {
    /// Exact match: result == expected means success.
    ///
    /// Use for syscalls where a specific value indicates success:
    /// - `close()` returns 0 on success
    /// - `munmap()` returns 0 on success
    ///
    /// ## Example
    ///
    /// ```swift
    /// try Kernel.Syscall.require(close(fd), .equals(0), orThrow: Error.current())
    /// ```
    @inlinable
    public static func equals(_ expected: T) -> Self {
        .init { $0 == expected }
    }

    /// Not equal: result != value means success.
    ///
    /// Use for syscalls with sentinel values:
    /// - `mmap()` returns MAP_FAILED on failure
    /// - Windows handles return INVALID_HANDLE_VALUE on failure
    ///
    /// ## Example
    ///
    /// ```swift
    /// let ptr = try Kernel.Syscall.require(
    ///     mmap(...),
    ///     .not(MAP_FAILED),
    ///     orThrow: Error.current()
    /// )
    /// ```
    @inlinable
    public static func not(_ value: T) -> Self {
        .init { $0 != value }
    }
}

// MARK: - Boolean Rules

extension Kernel.Syscall.Rule where T == Bool {
    /// Boolean is true (Windows BOOL).
    ///
    /// Use for Windows APIs that return BOOL where FALSE (0) indicates failure.
    ///
    /// ## Example
    ///
    /// ```swift
    /// try Kernel.Syscall.require(
    ///     ReadFile(...) != 0,
    ///     .isTrue,
    ///     orThrow: Error.current()
    /// )
    /// ```
    public static var isTrue: Self { .init { $0 } }
}

// MARK: - Optional Rules (Generic)

extension Kernel.Syscall.Rule {
    /// Value is not nil (works for any optional type).
    ///
    /// Use for APIs that return nil/NULL on failure:
    /// - Pointer-returning functions where nil indicates failure
    /// - Optional handle values
    ///
    /// ## Example
    ///
    /// ```swift
    /// let ptr = try Kernel.Syscall.require(
    ///     somePointerReturningCall(),
    ///     .notNil(),
    ///     orThrow: Error.current()
    /// )
    /// ```
    @inlinable
    public static func notNil<U>() -> Kernel.Syscall.Rule<U?> {
        .init { $0 != nil }
    }
}
