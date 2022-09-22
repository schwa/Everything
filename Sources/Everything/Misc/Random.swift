// swiftlint:disable identifier_name

import Foundation

extension RandomNumberGenerator {
    static var max: UInt64 {
        UInt64.max
    }
}

public protocol ConstrainedRandomNumberGenerator: RandomNumberGenerator {
    static var max: UInt64 { get }
}

// MARK: -

public extension RandomNumberGenerator {
    @available(*, deprecated, message: "UInt.random(in: 1...100). Code left in for reference.")
    mutating func random(uniform n: UInt64) -> UInt64 {
        // https://zuttobenkyou.wordpress.com/2012/10/18/generating-random-numbers-without-modulo-bias/
        let rand_excess = (Self.max % n) + 1
        let rand_limit = Self.max - rand_excess
        var x: UInt64
        repeat {
            x = next()
        }
        while x > rand_limit
        return x % n
    }
}

// MARK: -

// MARK: -

public protocol RandomInRange where Self: Comparable {
    static func random<R>(in: ClosedRange<Self>, using generator: inout R) -> Self where R: RandomNumberGenerator
}

extension Double: RandomInRange {
}

extension Float: RandomInRange {
}

extension Int: RandomInRange {
}

public extension Collection where Element: FloatingPoint & RandomInRange {
    func weightedRandomIndex<R>(using generator: inout R) -> Index where R: RandomNumberGenerator {
        let total = reduce(0, +)
        let cumulativeWeights = reduce(into: []) { accumulator, current in
            accumulator += [(accumulator.last ?? 0) + current]
        }
        let guess = Element.random(in: 0 ... total, using: &generator)
        let result = cumulativeWeights.enumerated().first { _, weight in
            guess < weight
        }

        let offset = result?.offset ?? count - 1
        return index(startIndex, offsetBy: offset)
    }

    func weightedRandomIndex() -> Index {
        var rng = SystemRandomNumberGenerator()
        return weightedRandomIndex(using: &rng)
    }
}

// MARK: -

// let s = UInt64(UInt(bitPattern: "hello world".strongHashValue))
// var r = SplitMix64()
// print((0..<16).map({ _ in r.random(uniform:100) }))
// let count = 1_000_000_000
// var data = Data(count: MemoryLayout<UInt32>.size * count)
// data.withUnsafeMutableBytes() {
//    (pointer: UnsafeMutablePointer <UInt32>) in
//
//    var pointer = pointer
//
//    for _ in 0..<count {
//
//        let n = r.next()
//
//        pointer.pointee = UInt32(0x0000_0000_FFFF_FFFF & n)
//        pointer = pointer.advanced(by: 1)
//    }
// }
// try! data.write(to: URL(fileURLWithPath: "/Users/schwa/Desktop/data.dat"))

// MARK: -

public class Arc4RandomRNG: ConstrainedRandomNumberGenerator {
    public static let max = UInt64(UInt32.max)

    public func next() -> UInt64 {
        // swiftlint:disable:next legacy_random
        UInt64(arc4random())
    }
}

// http://xoroshiro.di.unimi.it/xoroshiro128plus.c
public class Xoroshiro128Plus: RandomNumberGenerator {
    public typealias State = (UInt64, UInt64)

    public var s: State // = (0xbeac0467eba5facb, 0xd86b048b86aa9922)

    public required init(s: State) {
        self.s = s
    }

    public func next() -> UInt64 {
        func rotl(_ x: UInt64, _ k: Int) -> UInt64 {
            (x << k) | (x >> (64 - k))
        }
        let s0 = s.0
        var s1 = s.1
        let result = s0.addingReportingOverflow(s1).partialValue
        s1 ^= s0
        s.0 = rotl(s0, 55) ^ s1 ^ (s1 << 14) // a, b
        s.1 = rotl(s1, 36) // c
        return UInt64(result)
    }
}

public class SplitMix64: RandomNumberGenerator {
    // http://xorshift.di.unimi.it/splitmix64.c

    public var s: UInt64

    public required init(s: UInt64) {
        self.s = s
    }

    public func next() -> UInt64 {
        s = s &+ 0x9E37_79B9_7F4A_7C15
        var z = s
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return UInt64(z ^ (z >> 31))
    }
}
