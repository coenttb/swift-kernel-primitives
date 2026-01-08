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

extension Kernel.Memory {
    /// POSIX shared memory and Windows file mapping operations.
    ///
    /// Provides policy-free access to shared memory primitives:
    /// - POSIX: `shm_open` / `shm_unlink`
    /// - Windows: `CreateFileMappingW` / `OpenFileMappingW`
    ///
    /// ## Descriptor Lifecycle
    /// The returned descriptor must be mapped with ``Kernel/Memory/Map/map(_:length:protection:flags:offset:)``
    /// before use, then unmapped and closed when done.
    ///
    /// ## Concurrency
    /// Shared memory regions require explicit synchronization (mutexes, atomics)
    /// when accessed concurrently from multiple processes or threads.
    public enum Shared {}
}

// MARK: - Darwin Implementation

#if canImport(Darwin)

    public import Darwin
    public import CDarwinShim

    extension Kernel.Memory.Shared {
        /// Opens or creates a POSIX shared memory object.
        ///
        /// ## Threading
        /// This call may block briefly during kernel object creation/lookup.
        /// The returned descriptor can be used from any thread but requires
        /// explicit synchronization for the mapped memory region.
        ///
        /// ## Descriptor Lifecycle
        /// 1. Call `open()` to get a descriptor
        /// 2. Set size with `ftruncate()` if creating
        /// 3. Map with ``Kernel/Memory/Map/map(_:length:protection:flags:offset:)``
        /// 4. Use the mapped region (with synchronization)
        /// 5. Unmap with ``Kernel/Memory/Map/unmap(_:length:)``
        /// 6. Close with ``Kernel/Close/close(_:)``
        /// 7. Optionally unlink with ``unlink(name:)``
        ///
        /// ## Errors
        /// - ``Error/open(_:)``: shm_open failed (permission denied, name invalid, etc.)
        ///
        /// - Parameters:
        ///   - name: The name of the shared memory object (must start with '/').
        ///   - access: Read/write access mode.
        ///   - options: Creation options (create, exclusive, truncate).
        ///   - permissions: Permission mode for creation.
        /// - Returns: A file descriptor for the shared memory object.
        /// - Throws: ``Kernel/Memory/Shared/Error`` on failure.
        @inlinable
        public static func open(
            name: UnsafePointer<CChar>,
            access: Access,
            options: Options = [],
            permissions: Kernel.File.Permissions = .ownerReadWrite
        ) throws(Error) -> Kernel.Descriptor {
            let flags = access.posixFlags | options.posixFlags
            // Use shim because Darwin declares shm_open as variadic
            let fd = swift_shm_open(name, flags, mode_t(permissions.rawValue))
            guard fd >= 0 else {
                throw .open(.captureErrno())
            }
            return Kernel.Descriptor(rawValue: fd)
        }

        /// Removes a POSIX shared memory object.
        ///
        /// - Parameter name: The name of the shared memory object to remove.
        /// - Throws: `Error.unlink` on failure.
        @inlinable
        public static func unlink(name: UnsafePointer<CChar>) throws(Error) {
            guard shm_unlink(name) == 0 else {
                throw .unlink(.captureErrno())
            }
        }
    }

#endif

// MARK: - Linux Implementation

#if canImport(Glibc) || canImport(Musl)

    #if canImport(Glibc)
        public import Glibc
    #elseif canImport(Musl)
        public import Musl
    #endif

    extension Kernel.Memory.Shared {
        /// Opens or creates a POSIX shared memory object.
        ///
        /// ## Threading
        /// This call may block briefly during kernel object creation/lookup.
        /// The returned descriptor can be used from any thread but requires
        /// explicit synchronization for the mapped memory region.
        ///
        /// ## Descriptor Lifecycle
        /// 1. Call `open()` to get a descriptor
        /// 2. Set size with `ftruncate()` if creating
        /// 3. Map with ``Kernel/Memory/Map/map(_:length:protection:flags:offset:)``
        /// 4. Use the mapped region (with synchronization)
        /// 5. Unmap with ``Kernel/Memory/Map/unmap(_:length:)``
        /// 6. Close with ``Kernel/Close/close(_:)``
        /// 7. Optionally unlink with ``unlink(name:)``
        ///
        /// ## Errors
        /// - ``Error/open(_:)``: shm_open failed (permission denied, name invalid, etc.)
        ///
        /// - Parameters:
        ///   - name: The name of the shared memory object (must start with '/').
        ///   - access: Read/write access mode.
        ///   - options: Creation options (create, exclusive, truncate).
        ///   - permissions: Permission mode for creation.
        /// - Returns: A file descriptor for the shared memory object.
        /// - Throws: ``Kernel/Memory/Shared/Error`` on failure.
        @inlinable
        public static func open(
            name: UnsafePointer<CChar>,
            access: Access,
            options: Options = [],
            permissions: Kernel.File.Permissions = .ownerReadWrite
        ) throws(Error) -> Kernel.Descriptor {
            let flags = access.posixFlags | options.posixFlags
            let fd = shm_open(name, flags, mode_t(permissions.rawValue))
            guard fd >= 0 else {
                throw .open(.captureErrno())
            }
            return Kernel.Descriptor(rawValue: fd)
        }

        /// Removes a POSIX shared memory object.
        ///
        /// - Parameter name: The name of the shared memory object to remove.
        /// - Throws: `Error.unlink` on failure.
        @inlinable
        public static func unlink(name: UnsafePointer<CChar>) throws(Error) {
            guard shm_unlink(name) == 0 else {
                throw .unlink(.captureErrno())
            }
        }
    }

#endif

// MARK: - Windows Implementation

#if os(Windows)

    @preconcurrency public import WinSDK

    extension Kernel.Memory.Shared {
        /// Creates or opens a named shared memory object on Windows.
        ///
        /// Uses `CreateFileMappingW` with `INVALID_HANDLE_VALUE` to create
        /// pagefile-backed shared memory (equivalent to POSIX shm_open).
        ///
        /// - Parameters:
        ///   - name: The name of the shared memory object.
        ///     Unlike POSIX, Windows names don't require a "/" prefix.
        ///     Use "Local\\" prefix for session-local or "Global\\" for system-wide.
        ///   - size: The size of the shared memory region.
        ///     Required on Windows (unlike POSIX where size is set via ftruncate).
        ///   - access: Read/write access mode.
        ///   - options: Creation options.
        /// - Returns: A descriptor wrapping the Windows HANDLE.
        /// - Throws: `Error.open` on failure.
        ///
        /// ## Platform Differences
        ///
        /// - **Size required**: Windows requires size at creation, POSIX uses ftruncate
        /// - **Name format**: Windows uses "Local\\" or "Global\\" prefix, not "/"
        /// - **Truncate ignored**: Use `.create` only; resize is not supported
        /// - **Unlink behavior**: Windows objects are deleted when all handles close
        public static func open(
            name: String,
            size: Kernel.File.Size,
            access: Access,
            options: Options = []
        ) throws(Error) -> Kernel.Descriptor {
            // Convert size to high/low DWORD parts
            let sizeValue = UInt64(size.rawValue)
            let sizeHigh = DWORD((sizeValue >> 32) & 0xFFFF_FFFF)
            let sizeLow = DWORD(sizeValue & 0xFFFF_FFFF)

            let handle: HANDLE? = name.withCString(encodedAs: UTF16.self) { namePtr in
                if options.contains(.create) {
                    // Create new or open existing
                    return CreateFileMappingW(
                        HANDLE(bitPattern: -1),  // INVALID_HANDLE_VALUE - pagefile backed
                        nil,  // default security
                        access.windowsPageProtection,
                        sizeHigh,
                        sizeLow,
                        namePtr
                    )
                } else {
                    // Open existing only
                    return OpenFileMappingW(
                        access.windowsMapAccess,
                        false,  // don't inherit
                        namePtr
                    )
                }
            }

            guard let handle, handle != HANDLE(bitPattern: 0) else {
                throw .open(.captureLastError())
            }

            // Check for exclusive creation failure
            if options.contains(.exclusive) && options.contains(.create) {
                let lastError = GetLastError()
                if lastError == DWORD(ERROR_ALREADY_EXISTS) {
                    CloseHandle(handle)
                    throw .open(.captureLastError())
                }
            }

            return Kernel.Descriptor(rawValue: handle)
        }

        /// Opens an existing named shared memory object on Windows.
        ///
        /// - Parameters:
        ///   - name: The name of the shared memory object.
        ///   - access: Read/write access mode.
        /// - Returns: A descriptor wrapping the Windows HANDLE.
        /// - Throws: `Error.open` on failure.
        public static func open(
            name: String,
            access: Access
        ) throws(Error) -> Kernel.Descriptor {
            let handle: HANDLE? = name.withCString(encodedAs: UTF16.self) { namePtr in
                OpenFileMappingW(
                    access.windowsMapAccess,
                    false,  // don't inherit
                    namePtr
                )
            }

            guard let handle, handle != HANDLE(bitPattern: 0) else {
                throw .open(.captureLastError())
            }

            return Kernel.Descriptor(rawValue: handle)
        }

        /// Closes a shared memory object handle.
        ///
        /// On Windows, shared memory objects are reference-counted.
        /// The object is deleted when all handles are closed.
        ///
        /// - Note: This is different from POSIX where shm_unlink removes the name
        ///   but the object persists until all mappings are unmapped.
        ///
        /// - Parameter descriptor: The descriptor to close.
        /// - Throws: `Error.unlink` on failure.
        public static func close(_ descriptor: Kernel.Descriptor) throws(Error) {
            guard CloseHandle(descriptor.rawValue) else {
                throw .unlink(.captureLastError())
            }
        }
    }

#endif
