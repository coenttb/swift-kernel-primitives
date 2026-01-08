# Kernel Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/coenttb/swift-kernel-primitives/workflows/CI/badge.svg)](https://github.com/coenttb/swift-kernel-primitives/actions/workflows/ci.yml)

Type-safe, policy-free wrappers around platform kernel syscalls for Swift. Provides low-level I/O, memory mapping, threading primitives, and file operations with typed throws and full Sendable compliance.

---

## Key Features

- **Typed throws end-to-end** – Every error type is statically known; no `any Error` escapes the API surface
- **Swift 6 strict concurrency** – Full `Sendable` compliance with documented thread-safety guarantees
- **Cross-platform** – Unified API across macOS, Linux, and Windows with platform-specific optimizations
- **Policy-free design** – Raw syscall wrappers without opinions on scheduling, buffering, or lifecycle
- **Direct I/O support** – Aligned, unbuffered I/O for databases and high-performance applications
- **Memory mapping** – `mmap`/`VirtualAlloc` with page protection and synchronization controls
- **Zero Foundation dependency** – Pure Swift with minimal platform imports

---

## Installation

### Package.swift dependency

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-kernel-primitives.git", from: "0.1.0")
]
```

### Target dependency

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Kernel Primitives", package: "swift-kernel-primitives")
    ]
)
```

### Requirements

- Swift 6.2+
- macOS 26+ / iOS 26+ / tvOS 26+ / watchOS 26+ / Linux / Windows

---

## Quick Start

```swift
import Kernel_Primitives

// Open a file
let descriptor = try Kernel.File.Open.open(
    path: Kernel.Path("/tmp/data.txt"),
    mode: [.read, .write],
    options: [.create],
    permissions: .ownerReadWrite
)
defer { try? Kernel.Close.close(descriptor) }

// Write data
let message = "Hello, kernel!"
try message.utf8.withContiguousStorageIfAvailable { bytes in
    _ = try Kernel.IO.Write.write(descriptor, from: UnsafeRawBufferPointer(bytes))
}

// Read file stats
let stats = try Kernel.File.Stats.get(descriptor: descriptor)
print("Size: \(stats.size) bytes, Type: \(stats.type)")
```

---

## Architecture

| Type | Description |
|------|-------------|
| `Kernel.Descriptor` | Platform file descriptor (`int` / `HANDLE`) |
| `Kernel.File.Open` | File open operations with mode, options, permissions |
| `Kernel.File.Handle` | RAII wrapper with Direct I/O support and alignment tracking |
| `Kernel.File.Stats` | Cross-platform file metadata (size, type, times, permissions) |
| `Kernel.IO.Read` | Positional and sequential read operations |
| `Kernel.IO.Write` | Positional and sequential write operations |
| `Kernel.Memory.Map` | Memory-mapped I/O with protection and sync flags |
| `Kernel.Memory.Lock` | Page locking (`mlock` / `VirtualLock`) |
| `Kernel.Pipe` | Anonymous pipe creation |
| `Kernel.Socket` | Socket operations (see swift-posix for socket pairs) |
| `Kernel.Thread.Mutex` | Low-level mutex |
| `Kernel.Lock` | File locking |
| `Kernel.Copy` | Kernel-accelerated file copy with CoW support |
| `Kernel.Device` | Device identifier (see swift-posix for major/minor) |

> **Note:** POSIX-specific APIs (`mlockall`, `socketpair`, device major/minor) are in [swift-posix](https://github.com/coenttb/swift-posix).

---

## Platform Support

| Platform         | CI  | Status       |
|------------------|-----|--------------|
| macOS            | ✅  | Full support |
| Linux            | ✅  | Full support |
| Windows          | ✅  | Full support |
| iOS/tvOS/watchOS | —   | Supported    |

---

## Related Packages

### Dependencies

- [swift-standards](https://github.com/swift-standards/swift-standards): Binary data types and standards

### Used By

- [swift-kernel](https://github.com/coenttb/swift-kernel): Higher-level kernel abstractions
- [swift-io](https://github.com/coenttb/swift-io): Async I/O executor built on kernel primitives
- [swift-file-system](https://github.com/coenttb/swift-file-system): File system operations

---

## License

This project is licensed under the Apache License v2.0. See [LICENSE.md](LICENSE.md) for details.
