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
    /// Memory ordering for atomic loads.
    public enum Load {

    }
}

// MARK: - Operations

extension Kernel.Atomic {
    /// Performs a load with the specified memory ordering.
    ///
    /// - Parameters:
    ///   - pointer: The memory location to load from.
    ///   - ordering: The memory ordering for the load.
    /// - Returns: The value at the memory location.
    @inline(__always)
    public static func load<T>(
        _ pointer: UnsafeMutablePointer<T>,
        ordering: Load.Ordering
    ) -> T {
        switch ordering {
        case .relaxed:
            return pointer.pointee
        case .acquiring:
            let value = pointer.pointee
            _compilerBarrier(value)
            return value
        }
    }
}
