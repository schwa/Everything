// swiftlint:disable file_length

import Foundation

public extension Set {
    @discardableResult
    mutating func toggle(_ member: Element) -> Bool {
        if contains(member) {
            remove(member)
            return true
        }
        else {
            insert(member)
            return false
        }
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

public extension Collection where Element == UInt8 {
    func hexDump() {
        let offsetFormatter = IntegerStringFormatter(radix: 16, prefix: .none, leadingZeros: true, groupCount: nil, groupSeparator: "_", uppercase: true)
        let byteFormatter = IntegerStringFormatter(radix: 16, leadingZeros: true, uppercase: true)
        let bytesPerChunk = 16
        let s = chunks(of: bytesPerChunk).enumerated()
        .map { offset, chunk -> [String] in
            let offset = offsetFormatter.format(offset * bytesPerChunk)
            let bytes = chunk.map { byteFormatter.format($0) }.extend(repeating: "  ", to: bytesPerChunk).joined(separator: " ")
            let ascii = chunk.escapedAscii()
            return [offset, bytes, ascii]
        }
        .map { $0.joined(separator: " | ") }
        .joined(separator: "\n")
        print(s)
    }
}

public extension Collection where Element == UInt8 {
    func escapedAscii() -> String {
        map {
            UnicodeScalar($0).escapedString
        }
        .joined()
    }
}

public extension Collection {
    func sorted<Value>(by keyPath: KeyPath<Element, Value>) -> [Element] where Value: Comparable {
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

public extension Collection where Element == String {
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

/// [1,2,3,4,5].slidingWindow(3) -> [1,2,3], [2,3,4], [3,4,5]
public extension Sequence {
    func slidingWindow(_ windowCount: Int, closure: ([Iterator.Element]) -> Void) {
        var generator = makeIterator()
        var window = [Iterator.Element]()
        while window.count < windowCount {
            guard let next = generator.next() else {
                return
            }
            window.append(next)
        }
        closure(window)
        while true {
            window.removeFirst()
            guard let next = generator.next() else {
                return
            }
            window.append(next)
            closure(window)
        }
    }
}

/// [1,2,3,4,5,6,7,8,9,0].chunks(3) -> [1,2,3], [4,5,6], [7,8,9]
public extension Sequence {
    func chunks(_ chunkCount: Int, includeIncomplete: Bool = false, closure: ([Iterator.Element]) -> Void) {
        var generator = makeIterator()
        while true {
            var window = [Iterator.Element]()
            while window.count < chunkCount {
                guard let next = generator.next() else {
                    if includeIncomplete == true {
                        closure(window)
                    }
                    return
                }
                window.append(next)
            }
            closure(window)
        }
    }
}

public extension Collection {
    func split(by count: Int, includeIncomplete: Bool = false, reversed: Bool = false) -> [SubSequence] {
        var result: [SubSequence] = []
        chunkedRanges(count, includeIncomplete: includeIncomplete, reversed: reversed) { result.append(self[$0]) }
        return result
    }

    func ranges(of distance: Int, includeIncomplete: Bool = false, reversed: Bool = false) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        chunkedRanges(distance, includeIncomplete: includeIncomplete, reversed: reversed) { ranges.append($0) }
        return ranges
    }

    func chunkedRanges(_ chunkCount: Int, includeIncomplete: Bool = false, reversed: Bool = false, _ closure: (Range<Index>) throws -> Void) rethrows {
        assert(chunkCount > 0)
        switch reversed {
        case false:
            var current = startIndex
            var start: Index = current
            while current < endIndex {
                while current < endIndex {
                    current = index(after: current)
                    let distance = self.distance(from: start, to: current)
                    if distance == chunkCount {
                        try closure(start ..< current)
                        start = current
                    }
                }
            }
            if start < current && includeIncomplete {
                try closure(start ..< current)
            }
        case true:
            var current = endIndex
            var end: Index = current
            while current > startIndex {
                while current > startIndex {
                    current = index(current, offsetBy: -1)
                    let distance = self.distance(from: current, to: end)
                    if distance == chunkCount {
                        try closure(current ..< end)
                        end = current
                    }
                }
            }
            if end > current && includeIncomplete {
                try closure(current ..< end)
            }
        }
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

public extension Collection {
    func chunks(of count: Int) -> ChunksSequence<Self> {
        precondition(count > 0) // swiftlint:disable:this empty_count
        return ChunksSequence(base: self, count: count)
    }
}

public struct ChunksSequence<Base>: Sequence where Base: Collection {
    let base: Base
    let count: Int

    init(base: Base, count: Int) {
        self.base = base
        self.count = count
    }

    public func makeIterator() -> ChunksIterator<Base> {
        ChunksIterator<Base>(base: base, count: count)
    }
}

public struct ChunksIterator<Base>: IteratorProtocol where Base: Collection {
    public typealias Element = [Base.Iterator.Element]

    let base: Base
    let count: Int
    var baseIterator: Base.Iterator

    init(base: Base, count: Int) {
        self.base = base
        self.count = count
        baseIterator = base.makeIterator()
    }

    public mutating func next() -> Element? {
        baseIterator.next(count: count)
    }
}

// MARK: -

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
    func indexed() -> IndexedSequence<Self> {
        IndexedSequence(base: self)
    }
}

public struct IndexedSequence<Base>: Sequence where Base: Collection {
    let base: Base

    init(base: Base) {
        self.base = base
    }

    public func makeIterator() -> IndexedIterator<Base> {
        IndexedIterator<Base>(base: base)
    }
}

// TODO: Rename - too close to IndexingIterator

public struct IndexedIterator<Base>: IteratorProtocol where Base: Collection {
    public typealias Element = (index: Base.Index, element: Base.Iterator.Element)

    let base: Base
    var currentIndex: Base.Index
    var baseIterator: Base.Iterator

    init(base: Base) {
        self.base = base
        currentIndex = base.startIndex
        baseIterator = base.makeIterator()
    }

    public mutating func next() -> Element? {
        guard let element = baseIterator.next() else {
            return nil
        }
        let next = (index: currentIndex, element: element)
        currentIndex = base.index(after: currentIndex)
        return next
    }
}

// MARK: -

public extension Collection {
    func slidingWindow(_ windowSize: Int) -> SlidingWindowSequence<Self> {
        SlidingWindowSequence(base: self, windowSize: windowSize)
    }
}

public struct SlidingWindowSequence<Base>: Sequence where Base: Collection {
    let base: Base
    let windowSize: Int

    init(base: Base, windowSize: Int) {
        self.base = base
        self.windowSize = windowSize
    }

    public func makeIterator() -> SlidingWindowIterator<Base> {
        SlidingWindowIterator<Base>(base: base, windowSize: windowSize)
    }
}

public struct SlidingWindowIterator<Base>: IteratorProtocol where Base: Collection {
    public typealias Element = [Base.Iterator.Element]

    let base: Base
    let windowSize: Int
    var baseIterator: Base.Iterator
    var window: Element = []

    init(base: Base, windowSize: Int) {
        self.base = base
        self.windowSize = windowSize
        baseIterator = base.makeIterator()
    }

    public mutating func next() -> Element? {
        while window.count < windowSize {
            guard let element = baseIterator.next() else {
                return nil
            }
            window.append(element)
        }
        let result = window
        let slice = window.dropFirst()
        window = Array(slice)
        return result
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

    init(base: Base) {
        self.base = base
    }

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
