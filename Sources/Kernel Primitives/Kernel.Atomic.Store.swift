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

extension Kernel.Atomic {
    /// Memory ordering for atomic stores.
    public enum Store {

    }
}

// MARK: - Operations

extension Kernel.Atomic {
    /// Performs a store with the specified memory ordering.
    ///
    /// - Parameters:
    ///   - pointer: The memory location to store to.
    ///   - value: The value to store.
    ///   - ordering: The memory ordering for the store.
    @inline(__always)
    public static func store<T>(
        _ pointer: UnsafeMutablePointer<T>,
        _ value: T,
        ordering: Store.Ordering
    ) {
        switch ordering {
        case .relaxed:
            pointer.pointee = value
        case .releasing:
            _compilerBarrier(value)
            pointer.pointee = value
        }
    }
}
