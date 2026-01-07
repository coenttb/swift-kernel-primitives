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

extension Kernel {
    /// Pipe operations.
    public enum Pipe: Sendable {}
}

// MARK: - POSIX Implementation

#if canImport(Darwin)
    public import Darwin
#elseif canImport(Glibc)
    public import Glibc
#elseif canImport(Musl)
    public import Musl
#endif

#if canImport(Darwin) || canImport(Glibc) || canImport(Musl)

    extension Kernel.Pipe {
        /// Creates an anonymous pipe.
        ///
        /// - Returns: A tuple containing the read and write descriptors.
        /// - Throws: `Kernel.Pipe.Error` on failure.
        @inlinable
        public static func create() throws(Error) -> (read: Kernel.Descriptor, write: Kernel.Descriptor) {
            var fds: [Int32] = [0, 0]
            #if canImport(Darwin)
                try Kernel.Syscall.require(Darwin.pipe(&fds), .equals(0), orThrow: Error.current())
            #elseif canImport(Glibc)
                try Kernel.Syscall.require(Glibc.pipe(&fds), .equals(0), orThrow: Error.current())
            #elseif canImport(Musl)
                try Kernel.Syscall.require(Musl.pipe(&fds), .equals(0), orThrow: Error.current())
            #endif
            return (Kernel.Descriptor(rawValue: fds[0]), Kernel.Descriptor(rawValue: fds[1]))
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.Pipe {
        /// Creates an anonymous pipe.
        ///
        /// - Returns: A tuple containing the read and write descriptors.
        /// - Throws: `Kernel.Pipe.Error` on failure.
        @inlinable
        public static func create() throws(Error) -> (read: Kernel.Descriptor, write: Kernel.Descriptor) {
            var readHandle: HANDLE?
            var writeHandle: HANDLE?
            let result = CreatePipe(&readHandle, &writeHandle, nil, 0)
            try Kernel.Syscall.require(result, .isTrue, orThrow: Error.current())
            return (Kernel.Descriptor(rawValue: readHandle!), Kernel.Descriptor(rawValue: writeHandle!))
        }
    }

#endif
