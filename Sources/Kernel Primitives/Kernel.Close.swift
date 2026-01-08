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
    /// File descriptor close operations.
    ///
    /// Provides the fundamental `close()` syscall for releasing kernel resources.
    /// This is a policy-free wrapper; higher layers enforce ownership semantics.
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
        /// Closes a file descriptor, releasing the associated kernel resource.
        ///
        /// ## Threading
        /// This call blocks until the close completes. On most systems, close is fast,
        /// but may block on NFS or other networked filesystems while flushing data.
        ///
        /// ## Descriptor Invalidation
        /// After a successful close, the descriptor becomes invalid. Passing a closed
        /// descriptor to any operation is undefined behavior—the kernel may have
        /// reassigned the descriptor number to a new resource.
        ///
        /// ## Errors
        /// - ``Error/handle(_:)``: The descriptor is invalid (`.invalid`)
        /// - ``Error/io(_:)``: An I/O error occurred during close (data may be lost)
        /// - ``Error/interrupted``: Close was interrupted by a signal (descriptor state undefined on some platforms)
        ///
        /// - Parameter descriptor: The file descriptor to close.
        /// - Throws: ``Kernel/Close/Error`` on failure.
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
        /// Closes a file handle, releasing the associated kernel resource.
        ///
        /// ## Threading
        /// This call blocks until the close completes. CloseHandle is generally fast
        /// but may block for handles with pending I/O operations.
        ///
        /// ## Handle Invalidation
        /// After a successful close, the handle becomes invalid. Windows may reuse
        /// handle values immediately, so using a closed handle is undefined behavior.
        ///
        /// ## Errors
        /// - ``Error/handle(_:)``: The handle is invalid (`.invalid`)
        /// - ``Error/io(_:)``: An error occurred during close
        ///
        /// - Parameter descriptor: The file handle to close.
        /// - Throws: ``Kernel/Close/Error`` on failure.
        @inlinable
        public static func close(_ descriptor: Kernel.Descriptor) throws(Kernel.Close.Error) {
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }
            try Kernel.Syscall.require(CloseHandle(descriptor.rawValue), .isTrue, orThrow: Error.current())
        }
    }

#endif
