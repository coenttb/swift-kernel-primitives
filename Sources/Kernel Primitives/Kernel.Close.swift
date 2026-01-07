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
    public enum Close: Sendable {}
}

// MARK: - POSIX Implementation

#if !os(Windows)

    #if canImport(Darwin)
        public import Darwin
    #elseif canImport(Glibc)
        public import Glibc
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Close {
        /// Closes a file descriptor.
        @inlinable
        public static func close(_ descriptor: Kernel.Descriptor) throws(Kernel.Close.Error) {
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }
            #if canImport(Darwin)
                try Kernel.Syscall.require(Darwin.close(descriptor.rawValue), .equals(0), orThrow: Error.current())
            #elseif canImport(Glibc)
                try Kernel.Syscall.require(Glibc.close(descriptor.rawValue), .equals(0), orThrow: Error.current())
            #elseif canImport(Musl)
                try Kernel.Syscall.require(Musl.close(descriptor.rawValue), .equals(0), orThrow: Error.current())
            #endif
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.Close {
        /// Closes a file handle.
        @inlinable
        public static func close(_ descriptor: Kernel.Descriptor) throws(Kernel.Close.Error) {
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }
            try Kernel.Syscall.require(CloseHandle(descriptor.rawValue), .isTrue, orThrow: Error.current())
        }
    }

#endif
