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

public import Kernel_Primitives

extension Kernel.Event {
    /// Test utilities for eventing operations (kqueue, epoll, io_uring).
    public enum Test {
        /// Error thrown when pipe creation fails.
        public struct PipeError: Swift.Error, Sendable {
            public init() {}
        }

        /// Creates a pipe, returning (read, write) descriptors.
        ///
        /// - Returns: Tuple of (read descriptor, write descriptor)
        /// - Throws: `PipeError` if pipe creation fails
        public static func makePipe() throws -> (read: Kernel.Descriptor, write: Kernel.Descriptor) {
            do {
                return try Kernel.Pipe.create()
            } catch {
                throw PipeError()
            }
        }

        /// Closes a descriptor without throwing (safe for defer blocks).
        ///
        /// - Parameter fd: The descriptor to close
        public static func closeNoThrow(_ fd: Kernel.Descriptor) {
            try? Kernel.Close.close(fd)
        }

        /// Writes one byte to a descriptor.
        ///
        /// - Parameters:
        ///   - fd: The descriptor to write to
        ///   - value: The byte value to write (default: 1)
        public static func writeByte(_ fd: Kernel.Descriptor, value: UInt8 = 1) {
            var byte = value
            _ = withUnsafeBytes(of: &byte) { buffer in
                try? Kernel.IO.Write.write(fd, from: buffer)
            }
        }

        /// Drains one byte from a descriptor.
        ///
        /// - Parameter fd: The descriptor to read from
        public static func readDrain(_ fd: Kernel.Descriptor) {
            var byte: UInt8 = 0
            _ = withUnsafeMutableBytes(of: &byte) { buffer in
                try? Kernel.IO.Read.read(fd, into: buffer)
            }
        }
    }
}
