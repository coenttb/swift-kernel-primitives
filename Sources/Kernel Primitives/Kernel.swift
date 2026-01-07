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

/// The Kernel namespace provides syscall-shaped APIs for low-level OS operations.
///
/// Kernel exports only:
/// - Raw descriptors (`Kernel.Descriptor`)
/// - Raw buffers (`UnsafeRawBufferPointer`, `UnsafeMutableRawBufferPointer`)
/// - Primitive enums/option sets (`Kernel.File.Open.Mode`, `Kernel.File.Open.Options`)
/// - Unified error type (`Kernel.Error`)
/// - Path validation wrapper (`Kernel.Path`)
/// - System queries (`Kernel.System.pageSize`)
///
/// Kernel does NOT export:
/// - Policy (atomic writes, best-effort modes, retry logic)
/// - Discovery (capability probing, alignment requirements interpretation)
/// - Derived semantics (Direct I/O requirements, file type inference beyond stat)
/// - Third-party types (no `FilePath`, `FileDescriptor` from swift-system)
///
/// Higher layers (swift-io, swift-file-system) build semantics on top of Kernel.
public enum Kernel {}
