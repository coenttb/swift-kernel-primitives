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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#elseif os(Windows)
    public import WinSDK
#endif

extension Kernel {
    /// Environment variable access.
    ///
    /// Provides a Swift interface to environment variables without
    /// requiring direct C library imports in higher-level code.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// if Kernel.Environment.get("DEBUG") == "1" {
    ///     // Enable debug mode
    /// }
    /// ```
    public enum Environment {}
}

// MARK: - Get

extension Kernel.Environment {
    /// Gets the value of an environment variable.
    ///
    /// - Parameter name: The name of the environment variable.
    /// - Returns: The value if set, or `nil` if not set.
    public static func get(_ name: String) -> String? {
        #if os(Windows)
            return name.withCString(encodedAs: UTF16.self) { wname in
                let size = GetEnvironmentVariableW(wname, nil, 0)
                guard size > 0 else { return nil }

                var buffer = [WCHAR](repeating: 0, count: Int(size))
                let result = GetEnvironmentVariableW(wname, &buffer, size)
                guard result > 0, result < size else { return nil }

                if let nullIndex = buffer.firstIndex(of: 0) {
                    return String(decoding: buffer[..<nullIndex], as: UTF16.self)
                }
                return String(decoding: buffer, as: UTF16.self)
            }
        #else
            guard let ptr = getenv(name) else { return nil }
            return String(cString: ptr)
        #endif
    }

    /// Checks if an environment variable is set to a specific value.
    ///
    /// - Parameters:
    ///   - name: The name of the environment variable.
    ///   - value: The value to compare against.
    /// - Returns: `true` if the variable equals the value, `false` otherwise.
    @inlinable
    public static func isSet(_ name: String, to value: String) -> Bool {
        get(name) == value
    }

    /// Checks if an environment variable is set (regardless of value).
    ///
    /// - Parameter name: The name of the environment variable.
    /// - Returns: `true` if set, `false` if not set.
    @inlinable
    public static func isSet(_ name: String) -> Bool {
        get(name) != nil
    }
}
