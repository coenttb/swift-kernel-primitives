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

import Testing

/// Typed-throws test helper.
///
/// Use when Swift Testing macros would erase typed throws.
/// Prefer direct do/catch in non-throwing tests when possible.
///
/// - Parameters:
///   - validate: Closure to validate the thrown error
///   - body: The typed-throwing closure under test
public func expectThrows<E: Error, R>(
    _ validate: (E) -> Void,
    _ body: () throws(E) -> R
) {
    do {
        _ = try body()
        Issue.record("Expected error to be thrown")
    } catch {
        validate(error)
    }
}
