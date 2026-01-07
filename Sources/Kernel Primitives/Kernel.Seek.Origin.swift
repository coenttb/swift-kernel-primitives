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

extension Kernel.Seek {
    /// Reference point for seek operations.
    ///
    /// Determines where the offset parameter is measured from when seeking
    /// within a file. Combined with a signed offset, this allows positioning
    /// at any byte in the file.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Seek to absolute position 100
    /// let pos = try Kernel.Seek.seek(fd, offset: 100, origin: .start)
    ///
    /// // Move forward 50 bytes from current position
    /// let newPos = try Kernel.Seek.seek(fd, offset: 50, origin: .current)
    ///
    /// // Seek to 10 bytes before end of file
    /// let endPos = try Kernel.Seek.seek(fd, offset: -10, origin: .end)
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``Kernel/Seek/seek(_:offset:origin:)``
    public enum Origin: Sendable {
        /// Seeks from the beginning of the file.
        ///
        /// Offset 0 refers to the first byte. Positive offsets move toward EOF.
        /// Negative offsets are invalid and will fail.
        ///
        /// - POSIX: `SEEK_SET`
        /// - Windows: `FILE_BEGIN`
        case start

        /// Seeks relative to the current file offset.
        ///
        /// Positive offsets move toward EOF, negative toward the start.
        /// Seeking before byte 0 is invalid.
        ///
        /// - POSIX: `SEEK_CUR`
        /// - Windows: `FILE_CURRENT`
        case current

        /// Seeks relative to the end of file.
        ///
        /// Offset 0 refers to EOF (one past the last byte). Negative offsets
        /// move back into the file content. Positive offsets extend past EOF
        /// (creating a sparse file on write).
        ///
        /// - POSIX: `SEEK_END`
        /// - Windows: `FILE_END`
        case end
    }
}
