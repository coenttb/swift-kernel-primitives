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
    /// Semantic representation of operation interruption.
    ///
    /// Platform-agnostic abstraction over conditions like EINTR (POSIX).
    /// This type represents the *meaning* of interruption, not its platform-specific
    /// *provenance* (which remains in `Kernel.Signal` on POSIX platforms).
    ///
    /// ## Design Rationale
    ///
    /// Interruption is a cross-cutting execution condition, not a domain error.
    /// It is:
    /// - Not specific to any single operation (Close, Read, Write, etc.)
    /// - Not intrinsic to the operation's domain semantics
    /// - Platform-dependent in mechanism but uniform in meaning
    ///
    /// By separating interruption from domain errors, we achieve:
    /// - Domain-pure error types with zero `#if` guards
    /// - Uniform API surface across all platforms
    /// - Consumer-controlled retry policy
    ///
    /// ## Usage
    ///
    /// Interruption is surfaced via `Kernel.Outcome`, not embedded in domain errors:
    ///
    /// ```swift
    /// let outcome: Kernel.Outcome<Close.Error> = kernel.close(fd)
    /// switch outcome {
    /// case .success:
    ///     break
    /// case .failure(let error):
    ///     // Handle domain error
    /// case .interrupt(.occurred):
    ///     // Retry or propagate
    /// case .interrupt(.cancelled):
    ///     // Lifecycle shutdown, do not retry
    /// }
    /// ```
    public enum Interrupt: Sendable, Hashable {
        /// Operation was interrupted by an external condition.
        ///
        /// On POSIX: Maps from `EINTR` (syscall interrupted by signal).
        /// Retry typically succeeds.
        case occurred

        /// Operation was cancelled due to lifecycle/shutdown.
        ///
        /// Distinct from `.occurred` in that retry is not appropriate.
        /// The cancellation is intentional, not environmental.
        case cancelled
    }
}

// MARK: - Equatable

extension Kernel.Interrupt: Equatable {}

// MARK: - CustomStringConvertible

extension Kernel.Interrupt: CustomStringConvertible {
    public var description: String {
        switch self {
        case .occurred:
            return "interrupted"
        case .cancelled:
            return "cancelled"
        }
    }
}
