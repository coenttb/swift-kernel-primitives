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

extension Kernel.Socket.Shutdown {
    /// Specifies which half of the connection to shut down.
    public enum How: Int32, Sendable {
        /// Shut down the read side of the connection.
        case read = 0  // SHUT_RD

        /// Shut down the write side of the connection.
        case write = 1  // SHUT_WR

        /// Shut down both read and write sides.
        case both = 2  // SHUT_RDWR
    }
}

// MARK: - Windows Conversion

#if os(Windows)
    public import WinSDK

    extension Kernel.Socket.Shutdown.How {
        /// Converts to Windows SD_* constant.
        @usableFromInline
        internal var windowsValue: Int32 {
            switch self {
            case .read: return SD_RECEIVE
            case .write: return SD_SEND
            case .both: return SD_BOTH
            }
        }
    }
#endif
