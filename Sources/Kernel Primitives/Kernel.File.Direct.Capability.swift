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

extension Kernel.File.Direct {
    /// The Direct I/O capability of a file handle or path.
    ///
    /// Capability indicates whether Direct I/O can be used, not whether
    /// it is currently enabled. Use this to probe support before opening
    /// a file with `.direct` mode.
    ///
    /// ## Platform Capabilities
    ///
    /// | Platform | `.direct` | `.uncached` |
    /// |----------|-----------|-------------|
    /// | Linux | Filesystem-dependent | No |
    /// | Windows | Filesystem-dependent | No |
    /// | macOS | No | Always |
    public enum Capability: Sendable, Equatable {
        /// Strict Direct I/O is supported.
        ///
        /// The file or volume supports `O_DIRECT` (Linux) or
        /// `FILE_FLAG_NO_BUFFERING` (Windows) with known alignment requirements.
        case directSupported(Requirements.Alignment)

        /// Only best-effort uncached mode is supported (macOS).
        ///
        /// `fcntl(F_NOCACHE)` can be used, but no strict alignment
        /// requirements apply.
        case uncachedOnly

        /// Neither Direct I/O nor uncached mode is supported.
        ///
        /// Only buffered I/O is available.
        case bufferedOnly
    }
}

// MARK: - Direct Accessor

extension Kernel.File.Direct.Capability {
    /// Accessor for direct I/O properties.
    public var direct: Direct { Direct(capability: self) }

    /// Direct I/O properties accessor.
    public struct Direct: Sendable {
        let capability: Kernel.File.Direct.Capability

        init(capability: Kernel.File.Direct.Capability) {
            self.capability = capability
        }

        /// Whether strict Direct I/O is available.
        public var isSupported: Bool {
            if case .directSupported = capability { return true }
            return false
        }
    }
}

// MARK: - Bypass Accessor

extension Kernel.File.Direct.Capability {
    /// Accessor for cache bypass properties.
    public var bypass: Bypass { Bypass(capability: self) }

    /// Cache bypass properties accessor.
    public struct Bypass: Sendable {
        let capability: Kernel.File.Direct.Capability

        init(capability: Kernel.File.Direct.Capability) {
            self.capability = capability
        }

        /// Whether any form of cache bypass is available.
        public var isSupported: Bool {
            switch capability {
            case .directSupported, .uncachedOnly:
                return true
            case .bufferedOnly:
                return false
            }
        }
    }
}

// MARK: - Alignment

extension Kernel.File.Direct.Capability {
    /// The alignment requirements, if Direct I/O is supported.
    public var alignment: Kernel.File.Direct.Requirements.Alignment? {
        if case .directSupported(let alignment) = self {
            return alignment
        }
        return nil
    }
}
