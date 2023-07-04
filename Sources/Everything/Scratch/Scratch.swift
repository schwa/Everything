import Foundation

// TODO: Move all this

public extension Array {
    func extended(with element: Element, count: Int) -> Self {
        self + repeatElement(element, count: count - self.count)
    }
    
    func extended(with element: Element?, count: Int) -> [Element?] {
        self + repeatElement(element, count: count - self.count)
    }
}

public func inverseLerp(from lowerBound: Float, to upperBound: Float, by value: Float) -> Float {
    (value - lowerBound) / (upperBound - lowerBound)
}

extension CharacterSet: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = CharacterSet(charactersIn: value)
    }
}

public extension CharacterSet {
    static func + (lhs: CharacterSet, rhs: CharacterSet) -> CharacterSet {
        lhs.union(rhs)
    }
}

public extension Character {
    static func random(in set: String) -> Character {
        set.randomElement()!
    }
}

// MARK: -

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(string: value)!
    }
}

extension URL: ExpressibleByStringInterpolation {
}

public extension Optional where Wrapped: Collection {
    func nilify() -> Wrapped? {
        switch self {
        case .some(let value):
            if value.isEmpty {
                return nil
            }
            else {
                return value
            }
        case .none:
            return nil
        }
    }
}

public struct WeakBox<Content> where Content: AnyObject {
    public weak var content: Content?
    
    public init(_ content: Content) {
        self.content = content
    }
}

// MARK: -

public struct CompositeHash<Element>: Hashable where Element: Hashable {
    let elements: [Element]
    
    public init(_ elements: [Element]) {
        self.elements = elements
    }
}

extension CompositeHash: Sendable where Element: Sendable {
}

extension CompositeHash: Codable where Element: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        elements = try container.decode([Element].self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(elements)
    }
}

extension CompositeHash: Comparable where Element: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        let max = max(lhs.elements.count, rhs.elements.count)
        let lhs = lhs.elements.extended(count: max)
        let rhs = rhs.elements.extended(count: max)
        for (lhs, rhs) in zip(lhs, rhs) {
            switch (lhs, rhs) {
            case (.none, .none):
                fatalError("Should be impossible to be get here.")
            case (.some, .none):
                return false
            case (.none, .some):
                return true
            case (.some(let lhs), .some(let rhs)):
                if lhs < rhs {
                    return true
                }
                else if lhs > rhs {
                    return false
                }
                else {
                    continue
                }
            }
        }
        return false
    }
}

// MARK: -

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


// MARK: Metal

public extension IntSize {
    func contains(_ point: IntPoint) -> Bool {
        point.x >= 0 && point.x < width && point.y >= 0 && point.y < height
    }
}

public extension Array {
    mutating func mutate(_ block: (inout Element) throws -> Void) rethrows {
        try indexed().forEach { index, element in
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

// TODO: Move (maybe put in Rect)
public extension CGRect {
    init(_ scalars: [CGFloat]) {
        assert(!scalars.isEmpty)
        self = CGRect(x: scalars[0], y: scalars[1], width: scalars[2], height: scalars[3])
    }

    static func * (lhs: CGRect, rhs: CGSize) -> CGRect {
        CGRect(x: lhs.origin.x * rhs.width, y: lhs.origin.y * rhs.height, width: lhs.size.width * rhs.width, height: lhs.size.height * rhs.height)
    }

    static func / (lhs: CGRect, rhs: CGSize) -> CGRect {
        CGRect(x: lhs.origin.x / rhs.width, y: lhs.origin.y / rhs.height, width: lhs.size.width / rhs.width, height: lhs.size.height / rhs.height)
    }
}

// TODO: Move
public extension CGSize {
    init(_ size: IntSize) {
        self = CGSize(width: CGFloat(size.width), height: CGFloat(size.height))
    }
}

public extension CGRect {
    func unitPoint(_ p: CGPoint) -> CGPoint {
        origin + CGPoint(size) * p
    }
}

public extension RegularExpression.Match {
    struct CaptureGroups {
        public let match: RegularExpression.Match

        public subscript(index: Int) -> String {
            let range = match.result.range(at: index)
            let r2 = Range(range, in: match.string)!
            return String(match.string[r2])
        }

        public subscript(name: String) -> String {
            let range = match.result.range(withName: name)
            let r2 = Range(range, in: match.string)!
            return String(match.string[r2])
        }
    }

    var groups: CaptureGroups {
        CaptureGroups(match: self)
    }
}

public extension UInt8 {
    init(character: Character) {
        assert(character.utf8.count == 1)
        self = character.utf8.first!
    }
}

public extension Character {
    init(utf8: UInt8) {
        self = Character(UnicodeScalar(utf8))
    }
}

public extension Sequence<UInt8> {
    // djb2 - http://www.cse.yorku.ca/~oz/hash.html
    func djb2Hash() -> UInt {
        var hash: UInt = 5381
        for c in self {
            let c = UInt(c)
            hash = ((hash << 5) &+ hash) &+ c
        }
        return hash
    }
}

