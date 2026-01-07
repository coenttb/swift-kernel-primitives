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
    /// Permission domain - access control errors.
    ///
    /// These errors indicate the calling process lacks sufficient
    /// permissions to perform the requested operation.
    public enum Permission: Sendable {}
}
