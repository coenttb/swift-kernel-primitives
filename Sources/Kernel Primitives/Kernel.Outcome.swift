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
    /// Result wrapper that surfaces interruption explicitly.
    ///
    /// Unlike embedding interruption in domain error types, `Outcome` separates
    /// the cross-cutting concern of interruption from domain-specific failures.
    /// This allows consumers to decide retry policy.
    ///
    /// ## Design Rationale
    ///
    /// Domain errors should be domain-pure:
    /// - `Close.Error` contains only close-specific failures
    /// - `Read.Error` contains only read-specific failures
    ///
    /// Interruption (EINTR on POSIX) is not domain-specific. It can occur
    /// during any blocking syscall and represents an environmental condition,
    /// not a failure of the operation's semantics.
    ///
    /// By wrapping domain errors in `Outcome`, we:
    /// - Keep domain errors pure and uniform across platforms
    /// - Surface interruption explicitly for consumer-controlled retry
    /// - Eliminate `#if` guards from domain error types
    ///
    /// ## Usage
    ///
    /// ```swift
    /// func close(_ fd: Descriptor) -> Kernel.Outcome<Close.Error>
    ///
    /// switch kernel.close(fd) {
    /// case .success:
    ///     // Operation completed
    /// case .failure(let error):
    ///     // Handle domain error
    /// case .interrupt(.occurred):
    ///     // Retry or propagate
    /// case .interrupt(.cancelled):
    ///     // Lifecycle shutdown
    /// }
    /// ```
    public enum Outcome<Failure: Swift.Error & Sendable>: Sendable {
        /// Operation completed successfully (no return value).
        case success

        /// Operation failed with a domain-specific error.
        case failure(Failure)

        /// Operation was interrupted.
        case interrupt(Interrupt)
    }
}

// MARK: - Value variant

extension Kernel.Outcome {
    /// Outcome variant for operations that return a value on success.
    ///
    /// Use this when the operation produces a result, not just success/failure.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// func read(_ fd: Descriptor, into buffer: UnsafeMutableRawBufferPointer)
    ///     -> Kernel.Outcome<Read.Error>.Value<Int>
    ///
    /// switch kernel.read(fd, into: buffer) {
    /// case .success(let bytesRead):
    ///     // Process bytes
    /// case .failure(let error):
    ///     // Handle domain error
    /// case .interrupt(.occurred):
    ///     // Retry or propagate
    /// }
    /// ```
    public enum Value<Success: Sendable>: Sendable {
        /// Operation completed successfully with a value.
        case success(Success)

        /// Operation failed with a domain-specific error.
        case failure(Failure)

        /// Operation was interrupted.
        case interrupt(Kernel.Interrupt)
    }
}

// MARK: - Convenience initializers

extension Kernel.Outcome {
    /// Creates a success outcome.
    @inlinable
    public static var succeeded: Self { .success }
}

extension Kernel.Outcome.Value {
    /// Creates a success outcome with the given value.
    @inlinable
    public static func succeeded(_ value: Success) -> Self {
        .success(value)
    }
}

// MARK: - Throwing conversion

extension Kernel.Outcome {
    /// Converts to a throwing call, re-raising interruption as an error.
    ///
    /// Use when you want to propagate interruption as an error rather than
    /// handling it explicitly.
    @inlinable
    public func get() throws -> Void where Failure: Swift.Error {
        switch self {
        case .success:
            return
        case .failure(let error):
            throw error
        case .interrupt(let interrupt):
            throw Kernel.Interrupt.Thrown(interrupt)
        }
    }
}

extension Kernel.Outcome.Value {
    /// Converts to a throwing call, re-raising interruption as an error.
    @inlinable
    public func get() throws -> Success where Failure: Swift.Error {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        case .interrupt(let interrupt):
            throw Kernel.Interrupt.Thrown(interrupt)
        }
    }
}

// MARK: - Interrupt.Thrown

extension Kernel.Interrupt {
    /// Error type for when interruption is thrown rather than handled explicitly.
    public struct Thrown: Swift.Error, Sendable, Hashable {
        public let interrupt: Kernel.Interrupt

        @inlinable
        public init(_ interrupt: Kernel.Interrupt) {
            self.interrupt = interrupt
        }
    }
}

extension Kernel.Interrupt.Thrown: CustomStringConvertible {
    public var description: String {
        "operation \(interrupt)"
    }
}

// MARK: - Equatable

extension Kernel.Outcome: Equatable where Failure: Equatable {}
extension Kernel.Outcome.Value: Equatable where Success: Equatable, Failure: Equatable {}
