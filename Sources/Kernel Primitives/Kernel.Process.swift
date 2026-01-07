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
    /// Process-related types.
    public enum Process {}
}

extension Kernel.Process {
    /// Process group namespace.
    public enum Group {}
}

// MARK: - Process.ID

#if !os(Windows)

    #if canImport(Darwin)
        public import Darwin
    #elseif canImport(Glibc)
        public import Glibc
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Process {
        /// POSIX process ID.
        ///
        /// A type-safe wrapper for process identifiers used in signal sending
        /// and process management.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Send signal to a process
        /// try Kernel.Signal.Send.toProcess(.terminate, pid: .current)
        ///
        /// // Check if running as init
        /// if Kernel.Process.ID.current == .init {
        ///     // Running as PID 1
        /// }
        /// ```
        public typealias ID = Tagged<Kernel.Process, pid_t>
    }

    // MARK: - Process.ID Constants (POSIX)

    extension Tagged where Tag == Kernel.Process, RawValue == pid_t {
        /// The init process (pid 1).
        public static var `init`: Self { Self(1) }

        /// The current process.
        @inlinable
        public static var current: Self { Self(getpid()) }

        /// The parent process.
        @inlinable
        public static var parent: Self { Self(getppid()) }
    }

#else

    @preconcurrency public import WinSDK

    extension Kernel.Process {
        /// Windows process ID.
        ///
        /// A type-safe wrapper for Windows process identifiers.
        public typealias ID = Tagged<Kernel.Process, DWORD>
    }

    // MARK: - Process.ID Constants (Windows)

    extension Tagged where Tag == Kernel.Process, RawValue == DWORD {
        /// The current process ID.
        @inlinable
        public static var current: Self { Self(GetCurrentProcessId()) }
    }

#endif
