// swiftlint:disable file_length

import Foundation

public extension Set {
    @discardableResult
    mutating func toggle(_ member: Element) -> Bool {
        if contains(member) {
            remove(member)
            return true
        }
        insert(member)
        return false
    }
}

public extension Collection {
    func mutating(_ mutator: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try mutator(&copy)
        return copy
    }
}

public extension Array {
    init(tuple: (Element, Element)) {
        self = [tuple.0, tuple.1]
    }

    init(tuple: (Element, Element, Element)) {
        self = [tuple.0, tuple.1, tuple.2]
    }

    init(tuple: (Element, Element, Element, Element)) {
        self = [tuple.0, tuple.1, tuple.2, tuple.3]
    }
}

public extension Array {
    subscript(wrapping index: Index) -> Element {
        get {
            let index = (index >= 0 ? index : count + index)
            return self[index]
        }
        set {
            let index = (index >= 0 ? index : count + index)
            self[index] = newValue
        }
    }
}

public extension Array {
    func extend(repeating repeatedValue: Element, to count: Int) -> [Element] {
        if self.count >= count {
            return self
        }
        return self + Array(repeating: repeatedValue, count: count - self.count)
    }
}

public extension Array where Element: Equatable {
    mutating func remove(contentsOf elements: [Element]) {
        self = filter { element in
            elements.contains { $0 == element } == false
        }
    }
}

internal extension Array where Element: AnyObject {
    mutating func remove(contentsOf elements: [Element]) {
        self = filter { element in
            elements.contains { $0 === element }
        }
    }
}

public extension Array where Element: Equatable {
    func uniq() -> [Element] {
        reduce(into: []) { accumulator, current in
            if accumulator.contains(current) {
                return
            }
            accumulator += [current]
        }
    }
}

public extension Collection<UInt8> {
    func escapedAscii() -> String {
        map {
            UnicodeScalar($0).escapedString
        }
        .joined()
    }
}

public extension Collection {
    func sorted(by keyPath: KeyPath<Element, some Comparable>) -> [Element] {
        sorted {
            $0[keyPath: keyPath] < $1[keyPath: keyPath]
        }
    }
}

public extension Array {
    /// Given a blocking function that looks like `f(block: (Element) -> Void)` return all elements passed into the block. For non-blocking see Combine.
    init(gathering block: ((Element) -> Void) throws -> Void) rethrows {
        var elements: [Element] = []
        try block { element in
            elements.append(element)
        }
        self = elements
    }
}

public extension Collection<String> {
    func indented() -> [String] {
        map { element in
            "\t" + element
        }
    }
}

public extension IteratorProtocol {
    func eraseToAnyIterator() -> AnyIterator<Element> {
        AnyIterator(self)
    }

    func collect() -> [Element] {
        Array(AnyIterator(self))
    }
}

public struct NilIterator<Element>: IteratorProtocol {
    public mutating func next() -> Element? {
        nil
    }
}

public extension RangeReplaceableCollection {
    static func += (s: inout Self, e: Iterator.Element) {
        s.append(e)
    }
}

// MARK: -

public extension IteratorProtocol {
    mutating func next(count: Int) -> [Element]? {
        let elements: [Element] = (0 ..< count).reduce(into: []) { accumulator, _ in
            guard let element = next() else {
                return
            }
            accumulator += [element]
        }
        if elements.isEmpty {
            return nil
        }
        return elements
    }
}

// MARK: -

@available(*, deprecated, message: "Too specialised")
public struct Cursor<Iterator: IteratorProtocol>: IteratorProtocol {
    public private(set) var iterator: Iterator
    public private(set) var current: Iterator.Element?

    public init(_ iterator: Iterator) {
        self.iterator = iterator
    }

    public mutating func next() -> Iterator.Element? {
        current = iterator.next()
        return current
    }

    public mutating func advance() {
        current = iterator.next()
    }
}

// MARK: -

public extension Collection {
    func pairs() -> PairsSequence<Self> {
        PairsSequence(base: self)
    }
}

public struct PairsSequence<Base>: Sequence where Base: Collection {
    let base: Base

    public func makeIterator() -> PairsIterator<Base> {
        PairsIterator<Base>(base: base)
    }
}

public struct PairsIterator<Base>: IteratorProtocol where Base: Collection {
    public typealias Element = (Base.Iterator.Element, Base.Iterator.Element?)

    let base: Base
    var baseIterator: Base.Iterator

    init(base: Base) {
        self.base = base
        baseIterator = base.makeIterator()
    }

    public mutating func next() -> Element? {
        guard let first = baseIterator.next() else {
            return nil
        }
        let second = baseIterator.next()

        return (first, second)
    }
}

public extension Array {
    func extended(with element: Element, count: Int) -> Self {
        self + repeatElement(element, count: count - self.count)
    }

    func extended(with element: Element?, count: Int) -> [Element?] {
        self + repeatElement(element, count: count - self.count)
    }
}

public extension Collection {
    func extended(count: Int) -> [Element?] {
        let extra = count - self.count
        return map { Optional($0) } + repeatElement(nil, count: extra)
    }
}

public extension Collection where Element: Identifiable {
    func first(identifiedBy id: Element.ID) -> Element? {
        first { $0.id == id }
    }

    func firstIndex(identifiedBy id: Element.ID) -> Index? {
        firstIndex { $0.id == id }
    }
}

public extension Array {
    mutating func mutate(_ block: (inout Element) throws -> Void) rethrows {
        try enumerated().forEach { index, element in
            var element = element
            try block(&element)
            self[index] = element
        }
    }

    func mutated(_ block: (inout Element) throws -> Void) rethrows -> [Element] {
        try map { element in
            var element = element
            try block(&element)
            return element
        }
    }
}

public extension OptionSet {
    static func | (lhs: Self, rhs: Self) -> Self {
        lhs.union(rhs)
    }
}

public extension Collection {
    func counted() -> Self {
        print("\(count)")
        return self
    }
}

public extension Sequence<UInt8> {
    // djb2 - http://www.cse.yorku.ca/~oz/hash.html
    func djb2Hash() -> UInt {
        var hash: UInt = 5_381
        for c in self {
            let c = UInt(c)
            hash = ((hash << 5) &+ hash) &+ c
        }
        return hash
    }
}

public extension Sequence {
    func cast <T>(to: T.Type) -> [T?] {
        compactMap { $0 as? T }
    }
}

public extension Array where Element == UInt8 {
    mutating func append <Other>(contentsOf bytes: Other, alignment: Int) where Other: Sequence, Other.Element == UInt8 {
        let alignedPosition = align(offset: count, alignment: alignment)
        append(contentsOf: Array(repeating: 0, count: alignedPosition - count))
        append(contentsOf: bytes)
    }
}
