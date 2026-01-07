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

/// Test support for cross-platform temporary file paths.

public import Kernel_Primitives

// Platform imports only for getpid/GetCurrentProcessId (acceptable in test support)
#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#elseif os(Windows)
    import WinSDK
#endif

extension Kernel {
    /// Namespace for temporary path operations in tests.
    public enum Temporary {}
}

extension Kernel.Temporary {
    /// Returns the system temp directory path.
    ///
    /// Uses platform-appropriate environment variables:
    /// - Unix: `TMPDIR`, falling back to "/tmp"
    /// - Windows: `TEMP` or `TMP`, falling back to "C:\Temp"
    public static var directory: String {
        #if os(Windows)
            Kernel.Environment.get("TEMP")
                ?? Kernel.Environment.get("TMP")
                ?? "C:\\Temp"
        #else
            Kernel.Environment.get("TMPDIR") ?? "/tmp"
        #endif
    }

    /// Generates a unique temporary file path.
    ///
    /// - Parameter prefix: Prefix for the filename (e.g., "kernel-test").
    /// - Returns: A unique path string in the system temp directory.
    public static func filePath(prefix: String) -> String {
        #if os(Windows)
            let pid = Int(GetCurrentProcessId())
        #else
            let pid = Int(getpid())
        #endif
        let random = Int.random(in: 0..<Int.max)
        let name = "\(prefix)-\(pid)-\(random)"

        #if os(Windows)
            return directory + "\\" + name
        #else
            return directory + "/" + name
        #endif
    }
}
