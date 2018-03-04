// Copyright (c) 2018 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

/// A type that contains functions for reading `Data` bit-by-bit and byte-by-byte, assuming "LSB0" bit numbering scheme.
public final class LsbBitReader: ByteReader, BitReader {

    private var bitMask: UInt8 = 1
    private var currentByte: UInt8

    /// True, if reader's BIT pointer is aligned with the BYTE border.
    public var isAligned: Bool {
        return self.bitMask == 1
    }

    /// Amount of bits left to read.
    public var bitsLeft: Int {
        if self.isFinished {
            return 0
        } else {
            return (self.data.endIndex - self.offset) * 8 - self.bitMask.trailingZeroBitCount
        }
    }

    /// Amount of bits that were already read.
    public var bitsRead: Int {
        if self.isFinished {
            return 8 * self.size
        } else {
            return (self.offset - self.data.startIndex) * 8 + self.bitMask.trailingZeroBitCount
        }

    }

    /// Creates an instance for reading bits (and bytes) from `data`.
    public override init(data: Data) {
        self.currentByte = data.first ?? 0
        super.init(data: data)
    }

    /**
     Converts a `ByteReader` instance into `LsbBitReader`, enabling bit reading capabilities. Current `offset` value of
     `byteReader` is preserved.
     */
    public init(_ byteReader: ByteReader) {
        self.currentByte = byteReader.offset < byteReader.data.endIndex ? byteReader.data[byteReader.offset] : 0
        super.init(data: byteReader.data)
        self.offset = byteReader.offset
    }

    /**
     Reads bit and returns it, advancing by one BIT position.

     - Precondition: There MUST be enough data left.
     */
    public func bit() -> UInt8 {
        precondition(bitsLeft >= 1)
        let bit: UInt8 = self.currentByte & self.bitMask > 0 ? 1 : 0

        if self.bitMask == 128 {
            self.offset += 1
            self.bitMask = 1
        } else {
            self.bitMask <<= 1
        }

        return bit
    }

    /**
     Reads `count` bits and returns them as an array of `UInt8`, advancing by `count` BIT positions.

     - Precondition: Parameter `count` MUST not be less than 0.
     - Precondition: There MUST be enough data left.
     */
    public func bits(count: Int) -> [UInt8] {
        precondition(count >= 0)
        guard count > 0
            else { return [] }
        precondition(bitsLeft >= count)

        var array = [UInt8]()
        array.reserveCapacity(count)
        for _ in 0..<count {
            array.append(self.bit())
        }

        return array
    }

    /**
     Reads `count` bits and returns them as a `Int` number, advancing by `count` BIT positions.

     - Precondition: Parameter `fromBits` MUST not be less than 0.
     - Precondition: There MUST be enough data left.
     */
    public func int(fromBits count: Int) -> Int {
        precondition(count >= 0)
        guard count > 0
            else { return 0 }
        precondition(bitsLeft >= count)

        var result = 0
        for i in 0..<count {
            let bit = self.currentByte & self.bitMask > 0 ? 1 : 0
            result += (1 << i) * bit

            if self.bitMask == 128 {
                self.offset += 1
                self.bitMask = 1
            } else {
                self.bitMask <<= 1
            }
        }

        return result
    }

    /**
     Aligns reader's BIT pointer to the BYTE border, i.e. moves BIT pointer to the first BIT of the next BYTE.

     - Note: If reader is already aligned, then does nothing.
     - Warning: Doesn't check if there is any data left. It is advisable to use `isFinished` AFTER calling this method
     to check if the end was reached.
     */
    public func align() {
        guard self.bitMask != 1
            else { return }

        self.bitMask = 1
        self.offset += 1
    }

    // MARK: ByteReader's methods.

    /// Offset to the byte in `data` which will be read next.
    public override var offset: Int {
        didSet {
            if !self.isFinished {
                self.currentByte = self.data[self.offset]
            }
        }
    }

    /**
     Reads byte and returns it, advancing by one BYTE position.

     - Precondition: Reader MUST be aligned.
     - Precondition: There MUST be enough data left.
     */
    public override func byte() -> UInt8 {
        precondition(isAligned, "BitReader is not aligned.")
        return super.byte()
    }

    /**
     Reads `count` bytes and returns them as an array of `UInt8`, advancing by `count` BYTE positions.

     - Precondition: Reader MUST be aligned.
     - Precondition: There MUST be enough data left.
     */
    public override func bytes(count: Int) -> [UInt8] {
        precondition(isAligned, "BitReader is not aligned.")
        return super.bytes(count: count)
    }

    /**
     Reads 8 bytes and returns them as a `UInt64` number, advancing by 8 BYTE positions.

     - Precondition: Reader MUST be aligned.
     - Precondition: There MUST be enough data left.
     */
    public override func uint64() -> UInt64 {
        precondition(isAligned, "BitReader is not aligned.")
        return super.uint64()
    }

    /**
     Reads 4 bytes and returns them as a `UInt32` number, advancing by 4 BYTE positions.

     - Precondition: Reader MUST be aligned.
     - Precondition: There MUST be enough data left.
     */
    public override func uint32() -> UInt32 {
        precondition(isAligned, "BitReader is not aligned.")
        return super.uint32()
    }

    /**
     Reads 2 bytes and returns them as a `UInt16` number, advancing by 2 BYTE positions.

     - Precondition: Reader MUST be aligned.
     - Precondition: There MUST be enough data left.
     */
    public override func uint16() -> UInt16 {
        precondition(isAligned, "BitReader is not aligned.")
        return super.uint16()
    }

}
