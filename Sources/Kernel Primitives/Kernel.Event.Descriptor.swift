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

#if canImport(Glibc) || canImport(Musl)

    #if canImport(Glibc)
        public import Glibc
        public import CLinuxShim
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Event {
        /// Event file descriptor operations (Linux only).
        ///
        /// Event descriptors provide a simple mechanism for event notification.
        /// Common uses include waking up poll loops and inter-thread signaling.
        ///
        /// This namespace provides policy-free syscall wrappers.
        public enum Descriptor {}
    }

    // MARK: - Operations

    extension Kernel.Event.Descriptor {
        /// Creates a new eventfd descriptor.
        ///
        /// - Parameters:
        ///   - initval: Initial value of the counter (typically `.zero`).
        ///   - flags: Flags for the eventfd.
        /// - Returns: A file descriptor for the new eventfd.
        /// - Throws: `Error.create` if creation fails.
        @inlinable
        public static func create(
            initval: Kernel.Event.Counter = .zero,
            flags: Flags = .cloexec | .nonblock
        ) throws(Kernel.Event.Descriptor.Error) -> Kernel.Descriptor {
            let efd = eventfd(UInt32(initval), flags.rawValue)
            guard efd >= 0 else {
                throw .create(.captureErrno())
            }
            return Kernel.Descriptor(rawValue: efd)
        }

        /// Reads the counter value from an eventfd.
        ///
        /// After reading, the counter is reset to 0 (or decremented by 1 in semaphore mode).
        ///
        /// - Parameter efd: The eventfd descriptor.
        /// - Returns: The counter value.
        /// - Throws: `Error.read` on failure, `Error.wouldBlock` in non-blocking mode.
        @inlinable
        public static func read(_ efd: Kernel.Descriptor) throws(Kernel.Event.Descriptor.Error) -> Kernel.Event.Counter {
            var value: UInt64 = 0
            let result = withUnsafeMutablePointer(to: &value) { ptr in
                Glibc.read(efd.rawValue, ptr, MemoryLayout<UInt64>.size)
            }
            guard result == MemoryLayout<UInt64>.size else {
                let code = Kernel.Error.Code.captureErrno()
                if let posix = code.posix, posix == EAGAIN || posix == EWOULDBLOCK {
                    throw .wouldBlock
                }
                throw .read(code)
            }
            return Kernel.Event.Counter(rawValue: value)
        }

        /// Writes to an eventfd (increments counter).
        ///
        /// The value is added to the internal counter. The maximum counter value
        /// is `UInt64.max - 1`; if the add would overflow, the write blocks
        /// (or fails with EAGAIN in non-blocking mode).
        ///
        /// - Parameters:
        ///   - efd: The eventfd descriptor.
        ///   - value: The value to add to the counter (must not be UInt64.max).
        /// - Throws: `Error.write` on failure, `Error.wouldBlock` in non-blocking mode.
        @inlinable
        public static func write(_ efd: Kernel.Descriptor, value: Kernel.Event.Counter = .one) throws(Kernel.Event.Descriptor.Error) {
            var val = value.rawValue
            let result = withUnsafePointer(to: &val) { ptr in
                Glibc.write(efd.rawValue, ptr, MemoryLayout<UInt64>.size)
            }
            guard result == MemoryLayout<UInt64>.size else {
                let code = Kernel.Error.Code.captureErrno()
                if let posix = code.posix, posix == EAGAIN || posix == EWOULDBLOCK {
                    throw .wouldBlock
                }
                throw .write(code)
            }
        }

        /// Signals an eventfd (convenience for wakeup).
        ///
        /// Writes 1 to the eventfd counter. Ignores errors (fire-and-forget).
        /// Use this for waking up poll loops.
        ///
        /// - Parameter efd: The eventfd descriptor.
        @inlinable
        public static func signal(_ efd: Kernel.Descriptor) {
            var val: UInt64 = 1
            _ = withUnsafePointer(to: &val) { ptr in
                Glibc.write(efd.rawValue, ptr, MemoryLayout<UInt64>.size)
            }
        }
    }

#endif
