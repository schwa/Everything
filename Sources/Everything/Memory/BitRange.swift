import Foundation

// MARK: UnsignedIntegerTypes bitRanges

@inlinable
public func bitRange<T: UnsignedInteger>(value: T, start: Int, count: Int, flipped: Bool = false) -> T {
    assert(MemoryLayout<T>.size <= MemoryLayout<UInt64>.size)
    let bitSize = UInt64(MemoryLayout<T>.size * 8)
    assert(start + count <= Int(bitSize))
    if flipped {
        let shift = bitSize - UInt64(start) - UInt64(count)
        let mask = (UInt64(1) << UInt64(count)) - 1
        let intermediate = UInt64(value) >> shift & mask
        let result = intermediate
        return T(result)
    }
    let shift = UInt64(start)
    let mask = (UInt64(1) << UInt64(count)) - 1
    let result = UInt64(value) >> shift & mask
    return T(result)
}

@inlinable
public func bitRange<T: UnsignedInteger>(value: T, range: Range<Int>, flipped: Bool = false) -> T {
    bitRange(value: value, start: range.lowerBound, count: range.upperBound - range.lowerBound, flipped: flipped)
}

@inlinable
public func bitRange<T: UnsignedInteger>(value: T, range: ClosedRange<Int>, flipped: Bool = false) -> T {
    bitRange(value: value, start: range.lowerBound, count: range.upperBound - range.lowerBound + 1, flipped: flipped)
}

// MARK: UnsafeBufferPointer bitRanges

@inlinable
public func bitRange(buffer: UnsafeBufferPointer<some Any>, start: Int, count: Int) -> UInt64 {
    let rawPointer = UnsafeRawPointer(buffer.baseAddress)!

    // TODO: Swift3 - clean this up in the same manner (or better) we did bitSet (below)
    // Fast path; we want whole integers and the range is aligned to integer size.
    if count == 64, start.isMultiple(of: count) {
        return rawPointer.assumingMemoryBound(to: UInt64.self)[start / (MemoryLayout<UInt64>.size * 8)]
    }
    if count == 32, start.isMultiple(of: count) {
        return UInt64(rawPointer.assumingMemoryBound(to: UInt32.self)[start / (MemoryLayout<UInt32>.size * 8)])
    }
    if count == 16, start.isMultiple(of: count) {
        return UInt64(rawPointer.assumingMemoryBound(to: UInt16.self)[start / (MemoryLayout<UInt16>.size * 8)])
    }
    if count == 8, start.isMultiple(of: count) {
        return UInt64(rawPointer.assumingMemoryBound(to: UInt8.self)[start / (MemoryLayout<UInt8>.size * 8)])
    }
    // Slow(er) path. Range is not aligned.
    let pointer = rawPointer.assumingMemoryBound(to: UInt64.self)
    let wordSize = MemoryLayout<UInt64>.size * 8

    let end = start + count

    if start / wordSize == (end - 1) / wordSize {
        // Bit range does not cross two words
        let offset = start / wordSize
        return bitRange(value: pointer[offset].bigEndian, start: start % wordSize, count: count, flipped: true)
    }
    // Bit range spans two words, get bit ranges for both words and then combine them.
    let offset = start / wordSize
    let offsettedStart = start % wordSize
    let msw = bitRange(value: pointer[offset].bigEndian, range: offsettedStart ..< wordSize, flipped: true)
    let bits = (end - offset * wordSize) % wordSize
    let lsw = bitRange(value: pointer[offset + 1].bigEndian, range: 0 ..< bits, flipped: true)
    return msw << UInt64(bits) | lsw
}

@inlinable
public func bitRange(buffer: UnsafeBufferPointer<some Any>, range: Range<Int>) -> UInt64 {
    bitRange(buffer: buffer, start: range.lowerBound, count: range.upperBound - range.lowerBound)
}

// MARK: UnsignedIntegerType bitSets

@inlinable
public func bitSet<T: UnsignedInteger>(value: T, start: Int, count: Int, flipped: Bool = false, newValue: T) -> T {
    assert(start + count <= MemoryLayout<T>.size * 8)
    let mask: T = onesMask(start: start, count: count, flipped: flipped)
    let shift = UInt64(flipped == false ? start : (MemoryLayout<T>.size * 8 - start - count))
    let shiftedNewValue = UInt64(newValue) << UInt64(shift)
    let result = (UInt64(value) & UInt64(~mask)) | (shiftedNewValue & UInt64(mask))
    return T(result)
}

@inlinable
public func bitSet<T: UnsignedInteger>(value: T, range: Range<Int>, flipped: Bool = false, newValue: T) -> T {
    bitSet(value: value, start: range.lowerBound, count: range.upperBound - range.lowerBound, flipped: flipped, newValue: newValue)
}

@inlinable
public func bitSet<T: UnsignedInteger>(value: T, range: ClosedRange<Int>, flipped: Bool = false, newValue: T) -> T {
    bitSet(value: value, start: range.lowerBound, count: range.upperBound - range.lowerBound + 1, flipped: flipped, newValue: newValue)
}

// MARK: UnsafeMutableBufferPointer bitSets

@inlinable
public func bitSet(buffer: UnsafeMutableBufferPointer<some Any>, start: Int, count: Int, newValue: UInt64) {
    // TODO: Swift3 - why does return an optional?
    let pointer = UnsafeMutableRawPointer(buffer.baseAddress)!

    func set<T: UnsignedInteger>(pointer: UnsafeMutableRawPointer, type _: T.Type, newValue: UInt64) {
        pointer.assumingMemoryBound(to: T.self)[start / (MemoryLayout<T>.size * 8)] = T(newValue)
    }

    // Fast path; we want whole integers and the range is aligned to integer size.
    if count == 64, start.isMultiple(of: count) {
        set(pointer: pointer, type: UInt64.self, newValue: newValue)
    } else if count == 32, start.isMultiple(of: count) {
        set(pointer: pointer, type: UInt32.self, newValue: newValue)
    } else if count == 16, start.isMultiple(of: count) {
        set(pointer: pointer, type: UInt16.self, newValue: newValue)
    } else if count == 8, start.isMultiple(of: count) {
        set(pointer: pointer, type: UInt8.self, newValue: newValue)
    } else {
        // Slow(er) path. Range is not aligned.
        let pointer = pointer.assumingMemoryBound(to: UInt64.self)
        let wordSize = MemoryLayout<UInt64>.size * 8

        let end = start + count

        if start / wordSize == (end - 1) / wordSize {
            // Bit range does not cross two words

            let offset = start / wordSize
            let value = pointer[offset].bigEndian

            let result = UInt64(bigEndian: bitSet(value: value, start: start % wordSize, count: count, flipped: true, newValue: newValue))
            pointer[offset] = result
        } else {
            // Bit range spans two words, get bit ranges for both words and then combine them.
            unimplemented()
        }
    }
}

@inlinable
public func bitSet(buffer: UnsafeMutableBufferPointer<some Any>, range: Range<Int>, newValue: UInt64) {
    bitSet(buffer: buffer, start: range.lowerBound, count: range.upperBound - range.lowerBound, newValue: newValue)
}

// MARK: -

@usableFromInline
internal func onesMask<T: UnsignedInteger>(start: Int, count: Int, flipped: Bool = false) -> T {
    let size = UInt64(MemoryLayout<T>.size * 8)
    let start = UInt64(start)
    let count = UInt64(count)
    let shift = flipped == false ? start : (size - start - count)
    let mask = ((1 << count) - 1) << shift
    return T(mask)
}
