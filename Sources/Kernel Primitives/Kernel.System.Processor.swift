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

public import Binary

extension Kernel.System {
    /// Processor-related types.
    public enum Processor {}
}

// MARK: - Processor.Count

extension Kernel.System.Processor {
    /// Number of available processors.
    ///
    /// A type-safe wrapper for processor counts.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let cpuCount = Kernel.System.processor.count
    /// let workersPerCPU = 2
    /// let totalWorkers = Int(cpuCount) * workersPerCPU
    /// ```
    public typealias Count = Tagged<Kernel.System.Processor, Int>
}

// MARK: - Int Conversion

extension Int {
    /// Creates an Int from a processor count.
    @inlinable
    public init(_ count: Kernel.System.Processor.Count) {
        self = count.rawValue
    }
}
