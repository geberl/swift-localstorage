// Copyright (c) 2018 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

/// A type that contains functions for reading `Data` byte-by-byte.
public class ByteReader {

    /// Size of the `data` (in bytes).
    public let size: Int

    /// Data which is being read.
    public let data: Data

    /// Offset to the byte in `data` which will be read next.
    public var offset: Int

    /**
     True, if `offset` points at any position after the last byte in `data`.

     - Note: It generally means that all bytes have been read.
     */

    public var isFinished: Bool {
        return self.data.endIndex <= self.offset
    }

    /// Creates an instance for reading bytes from `data`.
    public init(data: Data) {
        self.size = data.count
        self.data = data
        self.offset = data.startIndex
    }

    /**
     Reads byte and returns it, advancing by one position.

     - Precondition: There MUST be enough data left.
     */
    public func byte() -> UInt8 {
        precondition(self.offset < self.data.endIndex)
        self.offset += 1
        return self.data[self.offset - 1]
    }

    /**
     Reads `count` bytes and returns them as an array of `UInt8`, advancing by `count` positions.

     - Precondition: Parameter `count` MUST not be less than 0.
     - Precondition: There MUST be enough data left.
     */
    public func bytes(count: Int) -> [UInt8] {
        precondition(count >= 0)
        guard count > 0
            else { return [] }
        precondition(self.offset + count <= self.data.endIndex)
        let result = self.data[self.offset..<self.offset + count].toArray(type: UInt8.self, count: count)
        self.offset += count
        return result
    }

    /**
     Reads 8 bytes and returns them as a `UInt64` number, advancing by 8 positions.

     - Precondition: There MUST be enough data left.
     */
    public func uint64() -> UInt64 {
        precondition(self.offset + 8 <= self.data.endIndex)
        let result = self.data[self.offset..<self.offset + 8].to(type: UInt64.self)
        self.offset += 8
        return result
    }

    /**
     Reads 4 bytes and returns them as a `UInt32` number, advancing by 4 positions.

     - Precondition: There MUST be enough data left.
     */
    public func uint32() -> UInt32 {
        precondition(self.offset + 4 <= self.data.endIndex)
        let result = self.data[self.offset..<self.offset + 4].to(type: UInt32.self)
        self.offset += 4
        return result
    }

    /**
     Reads 2 bytes and returns them as a `UInt16` number, advancing by 2 positions.

     - Precondition: There MUST be enough data left.
     */
    public func uint16() -> UInt16 {
        precondition(self.offset + 2 <= self.data.endIndex)
        let result = self.data[self.offset..<self.offset + 2].to(type: UInt16.self)
        self.offset += 2
        return result
    }

}
