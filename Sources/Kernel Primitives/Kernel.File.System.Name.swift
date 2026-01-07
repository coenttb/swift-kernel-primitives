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

public import Dimension

extension Kernel.File.System {
    /// Filename namespace for filesystem constraints.
    public enum Name {}
}

extension Kernel.File.System.Name {
    /// Maximum filename length in bytes.
    ///
    /// This represents `f_namelen` on Linux, `NAME_MAX` on Darwin,
    /// or `maxComponentLength` on Windows.
    public typealias Length = Tagged<Kernel.File.System.Name, UInt64>
}
