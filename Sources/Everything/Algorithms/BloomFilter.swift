import Foundation

struct BloomFilter<Element: Hashable> {
    let count: Int
    var storage: [UInt8]
    // swiftlint:disable:next opening_brace
    var hashFunctions: [(Element) -> Int] = [\.hashValue]

    init(count: Int) {
        self.count = count
        storage = [UInt8](repeating: 0, count: count / 8)
    }

    func contains(_ member: Element) -> Bool {
        for hashFunction in hashFunctions {
            let (index, shift) = indexShift(member, hashFunction: hashFunction)
            if (storage[index] & 1 << shift) == 0 {
                return false
            }
        }
        return true
    }

    mutating func insert(_ member: Element) {
        for hashFunction in hashFunctions {
            let (index, shift) = indexShift(member, hashFunction: hashFunction)
            storage[index] |= 1 << shift
        }
    }

    internal func indexShift(_ member: Element, hashFunction: (Element) -> Int) -> (Int, UInt8) {
        let hash = Int(bitPattern: UInt(bitPattern: hashFunction(member)) % UInt(count))
        let index = hash % storage.count
        let shift = UInt8(hash / storage.count)
        return (index, shift)
    }
}
