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

extension Kernel.Error {
    /// Unmapped domain - unmapped platform-specific errors.
    ///
    /// This is the escape hatch for errno/GetLastError codes that
    /// are not mapped to semantic error cases. Every syscall error
    /// type includes this as a case to ensure completeness.
    public enum Unmapped: Sendable {

    }
}
