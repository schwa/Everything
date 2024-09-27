import Foundation

public struct OrderedSet<Element> where Element: Hashable {
    internal var set: Set<Element>
    internal var array: [Element]

    public init() {
        set = []
        array = []
    }
}

extension OrderedSet: Sequence {
    public struct Iterator: IteratorProtocol {
        internal var base: Array<Element>.Iterator
        public mutating func next() -> Element? {
            base.next()
        }
    }

    public func makeIterator() -> Iterator {
        Iterator(base: array.makeIterator())
    }
}

extension OrderedSet: Collection {
    public struct Index: Comparable {
        internal let base: Array<Element>.Index

        public static func < (lhs: OrderedSet<Element>.Index, rhs: OrderedSet<Element>.Index) -> Bool {
            lhs.base < rhs.base
        }
    }

    public var startIndex: Index {
        Index(base: array.startIndex)
    }

    public var endIndex: Index {
        Index(base: array.endIndex)
    }

    public subscript(position: Index) -> Element {
        array[position.base]
    }

    public func index(after i: Index) -> Index {
        Index(base: array.index(after: i.base))
    }

    public var isEmpty: Bool {
        array.isEmpty
    }

    public var count: Int {
        array.count
    }
}

// extension OrderedSet: RandomAccessCollection {
//
// }

extension OrderedSet: SetAlgebra {
    public __consuming func union(_ other: __owned OrderedSet<Element>) -> OrderedSet<Element> {
        unimplemented()
    }

    public __consuming func intersection(_ other: OrderedSet<Element>) -> OrderedSet<Element> {
        unimplemented()
    }

    public __consuming func symmetricDifference(_ other: __owned OrderedSet<Element>) -> OrderedSet<Element> {
        unimplemented()
    }

    public mutating func insert(_ newMember: __owned Element) -> (inserted: Bool, memberAfterInsert: Element) {
        let result = set.insert(newMember)
        if result.inserted {
            array.append(newMember)
        }
        return result
    }

    public mutating func remove(_ member: Element) -> Element? {
        if let result = set.remove(member) {
            array.removeAll { $0 == result }
            return result
        }
        return nil
    }

    public mutating func update(with newMember: __owned Element) -> Element? {
        unimplemented()
        //        if let result = set.update(with: newMember) {
        //            unimplemented()
        //        }
        //        else {
        //            return nil
        //        }
    }

    public mutating func formUnion(_ other: __owned OrderedSet<Element>) {
        unimplemented()
    }

    public mutating func formIntersection(_ other: OrderedSet<Element>) {
        unimplemented()
    }

    public mutating func formSymmetricDifference(_ other: __owned OrderedSet<Element>) {
        unimplemented()
    }
}
