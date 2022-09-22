import Foundation

@frozen
public struct Bits<T> where T: BinaryInteger {
    @usableFromInline
    var value: T

    @usableFromInline
    init(value: T) {
        self.value = value
    }

    @usableFromInline
    static func mask(lowerBit: Int, upperBit: Int) -> T {
        let size = upperBit - lowerBit
        return T((2 << size - 1) << lowerBit)
    }

    @inlinable
    public subscript(range: ClosedRange<Int>) -> T {
        get {
            assert(range.lowerBound >= 0)
            assert(range.upperBound < MemoryLayout<T>.size * 8)
            let mask = Self.mask(lowerBit: range.lowerBound, upperBit: range.upperBound)
            return (value & mask) >> range.lowerBound
        }
        set {
            assert(range.lowerBound >= 0)
            assert(range.upperBound < MemoryLayout<T>.size * 8)
            let mask = Self.mask(lowerBit: range.lowerBound, upperBit: range.upperBound)
            value = value & ~mask | ((newValue << range.lowerBound) & mask)
        }
    }
}

public extension Bits {
    @inlinable
    subscript(range: Range<Int>) -> T {
        get {
            self[ClosedRange(range)]
        }
        set {
            self[ClosedRange(range)] = newValue
        }
    }

    @inlinable
    subscript(range: PartialRangeThrough<Int>) -> T {
        get {
            self[0 ... range.upperBound]
        }
        set {
            self[0 ... range.upperBound] = newValue
        }
    }

    @inlinable
    subscript(range: PartialRangeUpTo<Int>) -> T {
        get {
            self[0 ..< range.upperBound]
        }
        set {
            self[0 ..< range.upperBound] = newValue
        }
    }

    @inlinable
    subscript(range: PartialRangeFrom<Int>) -> T {
        get {
            let upperBound = MemoryLayout<T>.size * 8 - 1
            return self[range.lowerBound ... upperBound]
        }
        set {
            let upperBound = MemoryLayout<T>.size * 8 - 1
            self[range.lowerBound ... upperBound] = newValue
        }
    }
}

public extension BinaryInteger {
    @inlinable
    var bits: Bits<Self> {
        get {
            Bits(value: self)
        }
        set {
            self = newValue.value
        }
    }
}

public extension Bits {
    subscript(index: Int) -> T {
        get {
            self[index ... index]
        }
        set {
            self[index ... index] = newValue
        }
    }
}
