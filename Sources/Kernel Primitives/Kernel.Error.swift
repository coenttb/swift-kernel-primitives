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
    /// A throwable error carrying a raw platform error code.
    ///
    /// This is the transport layer for kernel errors in swift-kernel-primitives.
    /// It wraps `Kernel.Error.Code` (the raw errno/GetLastError value) and can
    /// be thrown directly or used as the fallback case in operation-specific
    /// typed errors.
    ///
    /// Semantic interpretation is provided by higher-level packages via
    /// extensions and the domain error types (`Permission.Error`, `IO.Error`, etc.).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Throwing raw platform error
    /// throw Kernel.Error(code: .captureErrno())
    ///
    /// // With context for debugging
    /// throw Kernel.Error.capturing(.captureErrno(), operation: "open")
    /// ```
    public struct Error: Swift.Error, Sendable, Equatable, Hashable {
        /// The raw platform error code.
        public let code: Code

        /// Optional diagnostic context.
        public let context: Context?

        /// Creates an error from a platform code.
        @inlinable
        public init(code: Code, context: Context? = nil) {
            self.code = code
            self.context = context
        }

        /// Creates an error capturing call-site context.
        @inlinable
        public static func capturing(
            _ code: Code,
            operation: StaticString,
            function: StaticString = #function,
            fileID: StaticString = #fileID,
            line: UInt32 = #line
        ) -> Self {
            Self(code: code, context: Context(
                operation: String(describing: operation),
                function: String(describing: function),
                fileID: String(describing: fileID),
                line: line
            ))
        }
    }
}

// MARK: - Context

extension Kernel.Error {
    /// Diagnostic context for debugging.
    public struct Context: Sendable, Equatable, Hashable {
        public let operation: String
        public let function: String
        public let fileID: String
        public let line: UInt32

        @inlinable
        public init(
            operation: String,
            function: String,
            fileID: String,
            line: UInt32
        ) {
            self.operation = operation
            self.function = function
            self.fileID = fileID
            self.line = line
        }
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Error: CustomStringConvertible {
    public var description: String {
        if let context {
            return "\(context.operation): \(code) at \(context.function) (\(context.fileID):\(context.line))"
        }
        return "kernel error: \(code)"
    }
}

// MARK: - Convenience Capture

extension Kernel.Error {
    /// Captures current platform error.
    @inlinable
    public static func current(
        operation: StaticString,
        function: StaticString = #function,
        fileID: StaticString = #fileID,
        line: UInt32 = #line
    ) -> Self {
        #if os(Windows)
        Self(code: .captureLastError(), context: Context(
            operation: String(describing: operation),
            function: String(describing: function),
            fileID: String(describing: fileID),
            line: line
        ))
        #else
        Self(code: .captureErrno(), context: Context(
            operation: String(describing: operation),
            function: String(describing: function),
            fileID: String(describing: fileID),
            line: line
        ))
        #endif
    }
}
