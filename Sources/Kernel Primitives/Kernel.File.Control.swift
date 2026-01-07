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

extension Kernel.File {
    /// File control operations (fcntl wrapper).
    public enum Control: Sendable {}
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

    extension Kernel.File.Control {
        /// Sets non-blocking mode on a file descriptor.
        ///
        /// - Parameter descriptor: The file descriptor to modify.
        /// - Throws: `Error` if fcntl fails.
        @inlinable
        public static func setNonBlocking(_ descriptor: Kernel.Descriptor) throws(Kernel.File.Control.Error) {
            #if canImport(Darwin)
                var flags = Darwin.fcntl(descriptor.rawValue, F_GETFL)
                guard flags >= 0 else {
                    throw Error.current()
                }
                let result = Darwin.fcntl(descriptor.rawValue, F_SETFL, flags | O_NONBLOCK)
                guard result >= 0 else {
                    throw Error.current()
                }
            #elseif canImport(Glibc)
                var flags = Glibc.fcntl(descriptor.rawValue, F_GETFL)
                guard flags >= 0 else {
                    throw Error.current()
                }
                let result = Glibc.fcntl(descriptor.rawValue, F_SETFL, flags | O_NONBLOCK)
                guard result >= 0 else {
                    throw Error.current()
                }
            #elseif canImport(Musl)
                var flags = Musl.fcntl(descriptor.rawValue, F_GETFL)
                guard flags >= 0 else {
                    throw Error.current()
                }
                let result = Musl.fcntl(descriptor.rawValue, F_SETFL, flags | O_NONBLOCK)
                guard result >= 0 else {
                    throw Error.current()
                }
            #endif
        }

        /// Clears non-blocking mode on a file descriptor.
        ///
        /// - Parameter descriptor: The file descriptor to modify.
        /// - Throws: `Error` if fcntl fails.
        @inlinable
        public static func setBlocking(_ descriptor: Kernel.Descriptor) throws(Kernel.File.Control.Error) {
            #if canImport(Darwin)
                var flags = Darwin.fcntl(descriptor.rawValue, F_GETFL)
                guard flags >= 0 else {
                    throw Error.current()
                }
                let result = Darwin.fcntl(descriptor.rawValue, F_SETFL, flags & ~O_NONBLOCK)
                guard result >= 0 else {
                    throw Error.current()
                }
            #elseif canImport(Glibc)
                var flags = Glibc.fcntl(descriptor.rawValue, F_GETFL)
                guard flags >= 0 else {
                    throw Error.current()
                }
                let result = Glibc.fcntl(descriptor.rawValue, F_SETFL, flags & ~O_NONBLOCK)
                guard result >= 0 else {
                    throw Error.current()
                }
            #elseif canImport(Musl)
                var flags = Musl.fcntl(descriptor.rawValue, F_GETFL)
                guard flags >= 0 else {
                    throw Error.current()
                }
                let result = Musl.fcntl(descriptor.rawValue, F_SETFL, flags & ~O_NONBLOCK)
                guard result >= 0 else {
                    throw Error.current()
                }
            #endif
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)
    public import WinSDK

    extension Kernel.File.Control {
        /// Sets non-blocking mode on a file handle.
        ///
        /// - Note: On Windows, non-blocking I/O requires OVERLAPPED structures
        ///   and cannot be set via a simple flag. This is a no-op placeholder.
        ///
        /// - Parameter descriptor: The file handle.
        @inlinable
        public static func setNonBlocking(_ descriptor: Kernel.Descriptor) throws(Kernel.File.Control.Error) {
            // Windows uses a different I/O model (IOCP/Overlapped)
            // Non-blocking semantics are achieved through async I/O, not flags
        }

        /// Clears non-blocking mode on a file handle.
        ///
        /// - Note: On Windows, this is a no-op as blocking is the default.
        ///
        /// - Parameter descriptor: The file handle.
        @inlinable
        public static func setBlocking(_ descriptor: Kernel.Descriptor) throws(Kernel.File.Control.Error) {
            // Windows handles are blocking by default
        }
    }

#endif
