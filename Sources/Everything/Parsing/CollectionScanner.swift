import Foundation

public struct CollectionScanner<C> where C: Collection {
    public typealias Element = C.Element
    public typealias SubSequence = C.SubSequence
    public typealias Index = C.Index

    public let elements: C

    public init(elements: C) {
        self.elements = elements
        current = self.elements.startIndex
    }

    public var current: Index {
        willSet {
            assert(current >= elements.startIndex)
            assert(current <= elements.endIndex)
        }
    }

    public var remaining: SubSequence {
        elements[current ..< elements.endIndex]
    }

    public var remainingCount: Int {
        elements.distance(from: current, to: elements.endIndex)
    }

    public var atEnd: Bool {
        elements.distance(from: current, to: elements.endIndex) == 0
    }

    public mutating func scan(count: Int) -> SubSequence? {
        guard !atEnd else {
            return nil
        }
        guard remainingCount >= count else {
            return nil
        }
        let result = elements[current ..< elements.index(current, offsetBy: count)]
        current = elements.index(current, offsetBy: count)
        return result
    }

    public func peek() -> Element? {
        if atEnd {
            return nil
        }
        return elements[current]
    }
}

public extension CollectionScanner where Element: Equatable {
    mutating func scan(value: Element) -> Bool {
        guard !atEnd else {
            return false
        }
        guard elements[current] == value else {
            return false
        }
        current = elements.index(current, offsetBy: 1)
        return true
    }

    mutating func scan(value: [Element]) -> Bool {
        let saved = current
        guard let scanned = scan(count: value.count) else {
            return false
        }
        guard Array(scanned) == value else {
            current = saved
            return false
        }
        return true
    }

    mutating func scanUpTo(value: Element, consuming: Bool = false) -> SubSequence? {
        guard !atEnd else {
            return nil
        }
        let index = remaining.firstIndex(of: value) ?? elements.endIndex
        let result = elements[current ..< index]
        current = index
        if consuming && !atEnd {
            current = elements.index(current, offsetBy: 1)
        }
        return result
    }

    // TODO: add a flag to control whether remaining to count as a match even if it doesnt end in a token
    mutating func scanUpTo(value: [Element], consuming: Bool = false) -> SubSequence? {
        assert(!value.isEmpty)
        guard !atEnd else {
            return nil
        }
        // TODO: Replace with https://en.wikipedia.org/wiki/Knuth–Morris–Pratt_algorithm where possible
        var remainingToSearch = remaining
        while !atEnd {
            if value.count > remainingToSearch.count {
                break
            }
            if let index = remainingToSearch.firstIndex(of: value.first!) {
                guard remainingToSearch.distance(from: index, to: remainingToSearch.endIndex) >= value.count else {
                    return nil
                }
                let hit = remainingToSearch[index ..< remainingToSearch.index(index, offsetBy: value.count)]
                // TODO: Is converting to an array slice efficient?
                if ArraySlice<Element>(hit) == value[value.startIndex ..< value.endIndex] {
                    current = index
                    let result = remainingToSearch[..<index]
                    if consuming && !atEnd {
                        current = elements.index(current, offsetBy: value.count)
                        return result
                    }
                    return result
                }
                remainingToSearch = remainingToSearch[index...]
            }
            else {
                break
            }
        }
        let result = remaining
        current = elements.endIndex
        return result
    }

    mutating func scan(componentsSeparatedBy separator: Element) -> [SubSequence] {
        guard !atEnd else {
            return []
        }
        let it = iterator(forComponentsSeparatedBy: separator)
        let result = it.collect()
        current = elements.endIndex // TODO: Is this always correct?
        return result
    }

    mutating func scan(anyOf elements: [Element]) -> Element? {
        guard let element = peek(), elements.contains(element) else {
            return nil
        }
        current = self.elements.index(current, offsetBy: 1)
        return element
    }
}

extension CollectionScanner where Element: Equatable {
    // TODO: This operates on a COPY of the Scanner
    func iterator(for block: @escaping (inout Self) -> SubSequence?) -> AnyIterator<SubSequence> {
        CollectionScannerIterator(scanner: self, block: block).eraseToAnyIterator()
    }

    // TODO: This operates on a COPY of the Scanner
    func iterator(forComponentsSeparatedBy separator: Element) -> AnyIterator<SubSequence> {
        iterator { scanner in
            if let result = scanner.scanUpTo(value: separator, consuming: true) {
                return result
            }
            return nil
        }
    }

    // TODO: This operates on a COPY of the Scanner
    func iterator(forComponentsSeparatedBy separator: [Element]) -> AnyIterator<SubSequence> {
        iterator { scanner in
            if let result = scanner.scanUpTo(value: separator, consuming: true) {
                return result
            }
            return nil
        }
    }
}

// TODO: This operates on a COPY of the Scanner
public struct CollectionScannerIterator<C>: IteratorProtocol where C: Collection, C.Element: Equatable {
    public typealias Scanner = CollectionScanner<C>
    var scanner: Scanner
    let block: (inout Scanner) -> Scanner.SubSequence?
    public mutating func next() -> Scanner.SubSequence? {
        if scanner.atEnd {
            return nil
        }
        return block(&scanner)
    }
}

extension CollectionScanner: CustomDebugStringConvertible {
    public var debugDescription: String {
        let startIndex = elements.distance(from: elements.startIndex, to: elements.startIndex)
        let endIndex = elements.distance(from: elements.startIndex, to: elements.endIndex)
        let current = elements.distance(from: elements.startIndex, to: self.current)
        return "\(startIndex) / \(endIndex) / \(current)"
    }
}

public extension CollectionScanner where Element == UInt8 {
    mutating func scan<T>(type t: T.Type) -> T? where T: BinaryFloatingPoint {
        let saved = current
        guard let array = scan(count: MemoryLayout<T>.size) else {
            return nil
        }
        return Array(array).withUnsafeBufferPointer { buffer -> T? in
            guard let pointer = buffer.baseAddress else {
                current = saved
                return nil
            }
            return pointer.withMemoryRebound(to: t, capacity: 1) { pointer in
                pointer.pointee
            }
        }
    }

    mutating func scan<T>(type t: T.Type) -> T? where T: BinaryInteger {
        let saved = current
        guard let array = scan(count: MemoryLayout<T>.size) else {
            return nil
        }
        return Array(array).withUnsafeBufferPointer { buffer in
            guard let pointer = buffer.baseAddress else {
                current = saved
                return nil
            }
            return pointer.withMemoryRebound(to: t, capacity: 1) { pointer in
                pointer.pointee
            }
        }
    }

    mutating func scan<T>(type t: T.Type, count: Int) -> [T]? where T: BinaryInteger {
        let values = (0 ..< count).compactMap { _ in
            scan(type: t)
        }
        assert(values.count == count)
        return values
    }

    mutating func scan<T>(type t: T.Type) -> T? where T: SIMD, T.Scalar: BinaryInteger {
        scan(type: t.Scalar.self, count: t.scalarCount).map { T($0) }
    }
}

public extension CollectionScanner {
    mutating func scan(until block: (Element) -> Bool) -> SubSequence? {
        guard !atEnd else {
            return nil
        }
        for index in remaining.indices {
            let element = remaining[index]
            if block(element) == true {
                let result = elements[current ..< index]
                current = index
                return result
            }
        }
        let result = remaining
        current = elements.endIndex
        return result
    }
}

public extension CollectionScanner {
    // Similar to SwiftUI.Path.path
    func scan<R>(block: (inout CollectionScanner) throws -> R) rethrows -> R {
        var scanner = self
        return try block(&scanner)
    }
}
