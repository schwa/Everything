import Foundation

public struct IdentifiableSet<Element> where Element: Identifiable {
    internal struct Box: Hashable {
        var key: Element.ID {
            element.id
        }

        let element: Element
        init(_ element: Element) {
            self.element = element
        }

        static func == (lhs: IdentifiableSet<Element>.Box, rhs: IdentifiableSet<Element>.Box) -> Bool {
            lhs.key == rhs.key
        }

        func hash(into hasher: inout Hasher) {
            key.hash(into: &hasher)
        }
    }

    internal typealias Storage = Set<Box>
    internal var storage: Storage

    internal init(storage: Storage) {
        self.storage = storage
    }

    public init() {
        storage = []
    }

    public init(_ elements: some Collection<Element>) {
        storage = Set(elements.map(Box.init))
    }
}

extension IdentifiableSet: Sequence {
    public struct Iterator: IteratorProtocol {
        internal var base: Storage.Iterator
        public mutating func next() -> Element? {
            base.next()?.element
        }
    }

    public func makeIterator() -> Iterator {
        Iterator(base: storage.makeIterator())
    }
}

extension IdentifiableSet: Collection {
    public struct Index: Comparable {
        internal let base: Storage.Index

        public static func < (lhs: IdentifiableSet<Element>.Index, rhs: IdentifiableSet<Element>.Index) -> Bool {
            lhs.base < rhs.base
        }
    }

    public var startIndex: Index {
        Index(base: storage.startIndex)
    }

    public var endIndex: Index {
        Index(base: storage.endIndex)
    }

    public subscript(position: Index) -> Element {
        storage[position.base].element
    }

    public func index(after i: Index) -> Index {
        Index(base: storage.index(after: i.base))
    }

    public var isEmpty: Bool {
        storage.isEmpty
    }

    public var count: Int {
        storage.count
    }
}

extension IdentifiableSet: SetAlgebra {
    public func contains(_ member: Element) -> Bool {
        storage.contains(Box(member))
    }

    public __consuming func union(_ other: __owned IdentifiableSet<Element>) -> IdentifiableSet<Element> {
        IdentifiableSet<Element>(storage: storage.union(other.storage))
    }

    public __consuming func intersection(_ other: IdentifiableSet<Element>) -> IdentifiableSet<Element> {
        IdentifiableSet<Element>(storage: storage.intersection(other.storage))
    }

    public __consuming func symmetricDifference(_ other: __owned IdentifiableSet<Element>) -> IdentifiableSet<Element> {
        IdentifiableSet<Element>(storage: storage.symmetricDifference(other.storage))
    }

    @discardableResult
    public mutating func insert(_ newMember: __owned Element) -> (inserted: Bool, memberAfterInsert: Element) {
        let result = storage.insert(Box(newMember))
        return (result.inserted, result.memberAfterInsert.element)
    }

    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        storage.remove(Box(member)).map(\.element)
    }

    @discardableResult
    public mutating func update(with newMember: __owned Element) -> Element? {
        storage.update(with: Box(newMember)).map(\.element)
    }

    public mutating func formUnion(_ other: __owned IdentifiableSet<Element>) {
        storage.formUnion(other.storage)
    }

    public mutating func formIntersection(_ other: IdentifiableSet<Element>) {
        storage.formIntersection(other.storage)
    }

    public mutating func formSymmetricDifference(_ other: __owned IdentifiableSet<Element>) {
        storage.formSymmetricDifference(other.storage)
    }

    public static func == (lhs: IdentifiableSet<Element>, rhs: IdentifiableSet<Element>) -> Bool {
        lhs.storage == rhs.storage
    }
}

extension IdentifiableSet: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self = Self(elements)
    }
}

extension IdentifiableSet: Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let elements = try container.decode([Element].self)
        self = Self(elements)
    }
}

extension IdentifiableSet: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let elements = storage.map(\.element)
        try container.encode(elements)
    }
}

extension IdentifiableSet: CustomStringConvertible {
    public var description: String {
        unimplemented()
    }
}

extension IdentifiableSet: CustomDebugStringConvertible {
    public var debugDescription: String {
        unimplemented()
    }
}

extension IdentifiableSet: Hashable where Element: Hashable {
}

// CustomReflectable
