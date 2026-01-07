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

// MARK: - Error Mapping
//
// Extension initializers that map platform error codes to domain errors.
// Each domain error type has init?(code:) that accepts a Kernel.Error.Code
// and extracts the appropriate platform-specific error code.

#if !os(Windows)

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    // MARK: - Path Resolution

    extension Kernel.Path.Resolution.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .posix(let errno) = code else { return nil }
            switch errno {
            case ENOENT: self = .notFound
            case EEXIST: self = .exists
            case EISDIR: self = .isDirectory
            case ENOTDIR: self = .notDirectory
            case ENOTEMPTY: self = .notEmpty
            case ELOOP: self = .loop
            case EXDEV: self = .crossDevice
            case ENAMETOOLONG: self = .nameTooLong
            default: return nil
            }
        }
    }

    // MARK: - Permission

    extension Kernel.Permission.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .posix(let errno) = code else { return nil }
            switch errno {
            case EACCES: self = .denied
            case EPERM: self = .notPermitted
            case EROFS: self = .readOnlyFilesystem
            default: return nil
            }
        }
    }

    // MARK: - Handle

    extension Kernel.Descriptor.Validity.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .posix(let errno) = code else { return nil }
            switch errno {
            case EBADF: self = .invalid
            case EMFILE: self = .limit(.process)
            case ENFILE: self = .limit(.system)
            default: return nil
            }
        }
    }

    // MARK: - Blocking

    extension Kernel.IO.Blocking.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .posix(let errno) = code else { return nil }
            switch errno {
            case EAGAIN, EWOULDBLOCK: self = .wouldBlock
            default: return nil
            }
        }
    }

    // MARK: - Space

    extension Kernel.Storage.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .posix(let errno) = code else { return nil }
            switch errno {
            case ENOSPC: self = .exhausted
            case EDQUOT: self = .quota
            default: return nil
            }
        }
    }

    // MARK: - Memory

    extension Kernel.Memory.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .posix(let errno) = code else { return nil }
            switch errno {
            case EFAULT: self = .fault
            case ENOMEM: self = .exhausted
            default: return nil
            }
        }
    }

    // MARK: - IO

    extension Kernel.IO.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .posix(let errno) = code else { return nil }
            switch errno {
            case EIO: self = .hardware
            case EPIPE: self = .broken
            case ECONNRESET: self = .reset
            case ESPIPE: self = .illegalSeek
            case ENOTSUP: self = .unsupported
            default: return nil
            }
        }
    }

    // MARK: - Lock

    extension Kernel.Lock.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .posix(let errno) = code else { return nil }
            switch errno {
            case ENOLCK: self = .unavailable
            case EDEADLK: self = .deadlock
            default: return nil
            }
        }
    }

    // MARK: - Platform (catch-all)

    extension Kernel.Error.Unmapped.Error {
        /// Creates a platform error from an error code.
        public init(code: Kernel.Error.Code) {
            self = .unmapped(code: code, message: nil)
        }
    }

#endif

// MARK: - Windows Error Mapping

#if os(Windows)
    public import WinSDK

    extension Kernel.Path.Resolution.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .win32(let error) = code else { return nil }
            switch Int32(error) {
            case ERROR_FILE_NOT_FOUND, ERROR_PATH_NOT_FOUND: self = .notFound
            case ERROR_FILE_EXISTS, ERROR_ALREADY_EXISTS: self = .exists
            case ERROR_DIRECTORY: self = .isDirectory
            case ERROR_DIRECTORY_NOT_SUPPORTED: self = .notDirectory
            case ERROR_DIR_NOT_EMPTY: self = .notEmpty
            case ERROR_NOT_SAME_DEVICE: self = .crossDevice
            default: return nil
            }
        }
    }

    extension Kernel.Permission.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .win32(let error) = code else { return nil }
            switch Int32(error) {
            case ERROR_ACCESS_DENIED: self = .denied
            default: return nil
            }
        }
    }

    extension Kernel.Descriptor.Validity.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .win32(let error) = code else { return nil }
            switch Int32(error) {
            case ERROR_INVALID_HANDLE: self = .invalid
            case ERROR_TOO_MANY_OPEN_FILES: self = .limit(.process)
            default: return nil
            }
        }
    }

    extension Kernel.Storage.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .win32(let error) = code else { return nil }
            switch Int32(error) {
            case ERROR_DISK_FULL: self = .exhausted
            default: return nil
            }
        }
    }

    extension Kernel.Memory.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .win32(let error) = code else { return nil }
            switch Int32(error) {
            case ERROR_NOT_ENOUGH_MEMORY, ERROR_OUTOFMEMORY: self = .exhausted
            default: return nil
            }
        }
    }

    extension Kernel.IO.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .win32(let error) = code else { return nil }
            switch Int32(error) {
            case ERROR_BROKEN_PIPE: self = .broken
            default: return nil
            }
        }
    }

    extension Kernel.IO.Blocking.Error {
        public init?(code: Kernel.Error.Code) {
            // Windows uses overlapped I/O rather than EAGAIN/EWOULDBLOCK
            // No direct equivalent, so always return nil
            return nil
        }
    }

    extension Kernel.Lock.Error {
        public init?(code: Kernel.Error.Code) {
            guard case .win32(let error) = code else { return nil }
            switch Int32(error) {
            case ERROR_LOCK_VIOLATION: self = .contention
            default: return nil
            }
        }
    }

    extension Kernel.Error.Unmapped.Error {
        /// Creates a platform error from an error code.
        public init(code: Kernel.Error.Code) {
            self = .unmapped(code: code, message: nil)
        }
    }

#endif
