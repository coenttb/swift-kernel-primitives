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

extension Kernel.Lock {
    /// Lock type determining concurrency behavior.
    ///
    /// File locks use reader-writer semantics: multiple readers can proceed
    /// concurrently, but writers require exclusive access.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Acquire a shared lock for reading
    /// try Kernel.Lock.lock(fd, range: .file, kind: .shared)
    /// defer { try? Kernel.Lock.unlock(fd, range: .file) }
    /// // Multiple processes can read concurrently
    ///
    /// // Acquire an exclusive lock for writing
    /// try Kernel.Lock.lock(fd, range: .file, kind: .exclusive)
    /// defer { try? Kernel.Lock.unlock(fd, range: .file) }
    /// // Only this process can access the file
    /// ```
    ///
    /// ## Compatibility
    ///
    /// | Held Lock | `.shared` request | `.exclusive` request |
    /// |-----------|-------------------|----------------------|
    /// | None | Granted | Granted |
    /// | `.shared` | Granted | Blocked |
    /// | `.exclusive` | Blocked | Blocked |
    ///
    /// ## See Also
    ///
    /// - ``Kernel/Lock/Range``
    /// - ``Kernel/Lock/lock(_:range:kind:)``
    public enum Kind: Sendable, Equatable, Hashable {
        /// Shared (read) lock allowing concurrent access.
        ///
        /// Multiple processes can hold shared locks on the same range simultaneously.
        /// Use for read-only access where concurrent reads are safe.
        ///
        /// - POSIX: `F_RDLCK`
        /// - Windows: `LOCKFILE_FAIL_IMMEDIATELY` without `LOCKFILE_EXCLUSIVE_LOCK`
        case shared

        /// Exclusive (write) lock preventing all other access.
        ///
        /// Only one process can hold an exclusive lock on a range. All other lock
        /// requests (shared or exclusive) will block or fail until released.
        ///
        /// - POSIX: `F_WRLCK`
        /// - Windows: `LOCKFILE_EXCLUSIVE_LOCK`
        case exclusive
    }
}
