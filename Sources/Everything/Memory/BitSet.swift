import Foundation

public struct BitSet {
    public private(set) var count: Int

    public private(set) var elements: [UInt]
    internal static let bitsPerElement = MemoryLayout<UInt>.size * 8

    internal static func minWordsNeededFor(count: Int) -> Int {
        Int(ceil(log(Double(count), base: Double(bitsPerElement))))
    }

    public init(count: Int, words: [UInt]) {
        assert(count <= words.count * Self.bitsPerElement, "Not enough words (\(words.count)) to store \(count) bits")
        assert(words.count <= Self.minWordsNeededFor(count: count), "Need only \(Self.minWordsNeededFor(count: count)) word(s) to store \(count) bits.")
        self.count = count
        elements = words
    }

    public subscript(index: Int) -> UInt {
        get {
            let element = index / Self.bitsPerElement
            let bit = index % Self.bitsPerElement
            return elements[element].bits[bit]
        }
        set {
            let element = index / Self.bitsPerElement
            let bit = index % Self.bitsPerElement
            elements[element].bits[bit] = newValue
        }
    }

    public subscript(range: ClosedRange<Int>) -> Self {
        get {
            unimplemented()
        }
        set {
            unimplemented()
        }
    }
}

public extension BitSet {
    init(count: Int) {
        self = BitSet(count: count, words: Array(repeating: 0, count: divup(dividend: count, divisor: BitSet.bitsPerElement)))
    }

    init<T>(_ value: T) where T: BinaryInteger {
        var value = value
        self = Swift.withUnsafeBytes(of: &value) { sourceBuffer in
            let count = MemoryLayout<T>.size * 8
            var elements = Array(repeating: UInt.zero, count: divup(dividend: count, divisor: BitSet.bitsPerElement))
            elements.withUnsafeMutableBytes { destinationBuffer in
                _ = sourceBuffer.copyBytes(to: destinationBuffer)
            }
            return BitSet(count: count, words: elements)
        }
    }
}

public extension BitSet {
    func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try elements.withUnsafeBytes(body) // TODO: Last word problem
    }

    mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        try elements.withUnsafeMutableBytes(body) // TODO: Last word problem
    }

    var bytes: [UInt8] {
        unimplemented()
    }
}

public extension BitSet {
    static prefix func ~ (bits: BitSet) -> BitSet {
        let words = Array(bits.elements.map { ~$0 })
        return BitSet(count: bits.count, words: words)
    }

    static func & (lhs: BitSet, rhs: BitSet) -> BitSet {
        let words = Array(zip(lhs.elements, rhs.elements).map { $0.0 & $0.1 })
        return BitSet(count: min(lhs.count, rhs.count), words: words)
    }

    static func &= (lhs: inout BitSet, rhs: BitSet) {
        lhs = lhs & rhs
    }

    static func | (lhs: BitSet, rhs: BitSet) -> BitSet {
        let words = Array(zip(lhs.elements, rhs.elements).map { $0.0 | $0.1 })
        return BitSet(count: min(lhs.count, rhs.count), words: words)
    }

    static func |= (lhs: inout BitSet, rhs: BitSet) {
        lhs = lhs | rhs
    }

    static func ^ (lhs: BitSet, rhs: BitSet) -> BitSet {
        let words = Array(zip(lhs.elements, rhs.elements).map { $0.0 ^ $0.1 })
        return BitSet(count: min(lhs.count, rhs.count), words: words)
    }

    static func ^= (lhs: inout BitSet, rhs: BitSet) {
        lhs = lhs ^ rhs
    }
}
