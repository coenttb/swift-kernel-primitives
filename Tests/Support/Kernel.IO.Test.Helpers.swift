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

#if !os(Windows)

    public import Kernel_Primitives

    /// Test utilities for I/O operations.
    public enum KernelIOTest {
        /// Error thrown when temp file creation fails.
        public struct TempFileError: Swift.Error, Sendable {
            public init() {}
        }

        // MARK: - Legacy tuple-returning helpers (for existing tests)

        /// Creates a temporary file and returns its path string and descriptor.
        /// Caller is responsible for cleanup via `cleanupTempFile`.
        public static func createTempFile(prefix: String = "io-test") throws -> (path: String, fd: Kernel.Descriptor) {
            let pathString = Kernel.Temporary.filePath(prefix: prefix)
            let fd = try Kernel.Path.scope(pathString) { path in
                try Kernel.File.Open.open(
                    path: path,
                    mode: [.read, .write],
                    options: [.create, .truncate, .exclusive],
                    permissions: .ownerReadWrite
                )
            }
            return (pathString, fd)
        }

        /// Creates a temporary file with content and returns its path string and descriptor.
        /// Caller is responsible for cleanup via `cleanupTempFile`.
        public static func createTempFileWithContent(_ content: String, prefix: String = "io-test") throws -> (path: String, fd: Kernel.Descriptor) {
            let (pathString, fd) = try createTempFile(prefix: prefix)
            var contentBytes = Array(content.utf8)
            _ = try? contentBytes.withUnsafeMutableBytes { ptr in
                try Kernel.IO.Write.write(fd, from: UnsafeRawBufferPointer(ptr))
            }
            return (pathString, fd)
        }

        /// Cleans up a temporary file created by `createTempFile` or `createTempFileWithContent`.
        public static func cleanupTempFile(path: String, fd: Kernel.Descriptor) {
            try? Kernel.Close.close(fd)
            try? Kernel.Path.scope(path) { p in
                try Kernel.Unlink.unlink(p)
            }
        }

        // MARK: - Closure-based helpers (preferred)

        /// Creates a temporary file and executes the body with path and descriptor.
        ///
        /// The file is automatically cleaned up after the body completes.
        ///
        /// - Parameters:
        ///   - prefix: Prefix for the temp file name (default: "io-test")
        ///   - body: Closure receiving the path and descriptor
        /// - Returns: The value returned by the body
        /// - Throws: `TempFileError` if creation fails, or rethrows from body
        public static func withTempFile<R>(
            prefix: String = "io-test",
            _ body: (borrowing Kernel.Path, Kernel.Descriptor) throws -> R
        ) throws -> R {
            let pathString = Kernel.Temporary.filePath(prefix: prefix)
            return try Kernel.Path.scope(pathString) { path in
                let fd: Kernel.Descriptor
                do {
                    fd = try Kernel.File.Open.open(
                        path: path,
                        mode: [.read, .write],
                        options: [.create, .truncate, .exclusive],
                        permissions: .ownerReadWrite
                    )
                } catch {
                    throw TempFileError()
                }
                defer {
                    try? Kernel.Close.close(fd)
                    try? Kernel.Unlink.unlink(path)
                }
                return try body(path, fd)
            }
        }

        /// Creates a temporary file with initial content and executes the body.
        ///
        /// The file is automatically cleaned up after the body completes.
        ///
        /// - Parameters:
        ///   - content: The string content to write
        ///   - prefix: Prefix for the temp file name (default: "io-test")
        ///   - body: Closure receiving the path and descriptor
        /// - Returns: The value returned by the body
        /// - Throws: `TempFileError` if creation fails, or rethrows from body
        public static func withTempFile<R>(
            content: String,
            prefix: String = "io-test",
            _ body: (borrowing Kernel.Path, Kernel.Descriptor) throws -> R
        ) throws -> R {
            try withTempFile(prefix: prefix) { path, fd in
                var contentBytes = Array(content.utf8)
                _ = try? contentBytes.withUnsafeMutableBytes { ptr in
                    try Kernel.IO.Write.write(fd, from: UnsafeRawBufferPointer(ptr))
                }
                return try body(path, fd)
            }
        }

        /// Creates a temporary file for Handle tests and executes the body.
        ///
        /// The file is automatically cleaned up after the body completes.
        ///
        /// - Parameters:
        ///   - content: Optional string content to write
        ///   - prefix: Prefix for the temp file name (default: "handle-test")
        ///   - body: Closure receiving the path and File.Descriptor
        /// - Returns: The value returned by the body
        /// - Throws: `TempFileError` if creation fails, or rethrows from body
        public static func withTempFileForHandle<R>(
            content: String? = nil,
            prefix: String = "handle-test",
            _ body: (borrowing Kernel.Path, Kernel.File.Descriptor) throws -> R
        ) throws -> R {
            let pathString = Kernel.Temporary.filePath(prefix: prefix)
            return try Kernel.Path.scope(pathString) { path in
                let fd: Kernel.Descriptor
                do {
                    fd = try Kernel.File.Open.open(
                        path: path,
                        mode: [.read, .write],
                        options: [.create, .truncate, .exclusive],
                        permissions: .ownerReadWrite
                    )
                } catch {
                    throw TempFileError()
                }

                if let content = content {
                    var contentBytes = Array(content.utf8)
                    _ = try? contentBytes.withUnsafeMutableBytes { ptr in
                        try Kernel.IO.Write.write(fd, from: UnsafeRawBufferPointer(ptr))
                    }
                }

                defer {
                    try? Kernel.Close.close(fd)
                    try? Kernel.Unlink.unlink(path)
                }

                return try body(path, Kernel.File.Descriptor(rawValue: fd.rawValue))
            }
        }
    }

#endif
