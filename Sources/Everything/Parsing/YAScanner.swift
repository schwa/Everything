import CoreGraphics
import Foundation

// TODO: Deprecate
// @available(*, deprecated, message: "Use Scanner or CollectionScanner instead?")
open class YAScanner: IteratorProtocol {
    public typealias Element = Character

    public let characters: String
    open var location: String.Index
    open var skippedCharacters: YACharacterSet?

    public init(string: String) {
        characters = string
        location = string.startIndex
        skippedCharacters = YACharacterSet.whitespaces
    }

    open var atEnd: Bool {
        location == characters.endIndex
    }

    open var remaining: String {
        String(characters[location ..< characters.endIndex])
    }

    open var remainingCharacters: String {
        String(characters[location ..< characters.endIndex])
    }

    open func suppressSkip<T>(_ closure: () -> T) -> T {
        let savedSkippedCharacters = skippedCharacters
        skippedCharacters = nil
        let result = closure()
        skippedCharacters = savedSkippedCharacters
        return result
    }

    open func next() -> Character? {
        if location >= characters.endIndex {
            return nil
        }
        let value = characters[location]
        location = characters.index(location, offsetBy: 1)
        return value
    }

    open func back() throws {
        guard location != characters.startIndex else {
            throw GeneralError.generic("Underflow")
        }
        location = characters.index(location, offsetBy: -1)
    }

    open func skip() {
        guard let skippedCharacters else {
            return
        }
        for C in self where skippedCharacters.contains(C) == false {
            forceTry {
                try back()
            }
            break
        }
    }
}

// MARK: SequenceType

extension YAScanner: Sequence {
    public typealias Iterator = YAScanner
    public func makeIterator() -> Iterator {
        self
    }
}

// MARK: CustomStringConvertible

extension YAScanner: CustomStringConvertible {
    public var description: String {
        let prefix = String(characters.prefix(upTo: location))
        let suffix = String(characters.suffix(from: location))
        return "[\(prefix)] <|> [\(suffix)]"
    }
}

// MARK: Transactions

public extension YAScanner {
    func with(closure: () throws -> Bool) rethrows -> Bool {
        let savedLocation = location
        let result = try closure()
        if result == false {
            location = savedLocation
        }
        return result
    }

    func with<T>(closure: () throws -> T?) rethrows -> T? {
        let savedLocation = location
        let result = try closure()
        if result == nil {
            location = savedLocation
        }
        return result
    }
}

// MARK: Primitive Types

public extension YAScanner {
    func scan(string: String) -> Bool {
        assert(string.isEmpty == false)

        return with {
            skip()
            var searchStringGenerator = string.makeIterator()
            while true {
                let searchStringGeneratorValue = searchStringGenerator.next()
                if searchStringGeneratorValue == nil {
                    return true
                }
                let stringGeneratorValue = next()
                if stringGeneratorValue == nil {
                    break
                }
                if searchStringGeneratorValue != stringGeneratorValue {
                    break
                }
            }
            return false
        }
    }

    func scan(character: Character) -> Bool {
        with {
            skip()
            return character == next()
        }
    }

    func scan(characterFromSet characterSet: YACharacterSet) -> Character? {
        with {
            skip()
            if let character = next() {
                if characterSet.contains(character) {
                    return character
                }
            }
            return nil
        }
    }

    func scan(charactersFromSet characterSet: YACharacterSet) -> String? {
        with {
            skip()
            let start = location
            for C in self where characterSet.contains(C) == false {
                forceTry {
                    try back()
                }
                break
            }

            guard characters.distance(from: start, to: location) > 0 else {
                return nil
            }

            return String(characters[start ..< location])
        }
    }

    // TODO: Replace with regex
    internal static let floatingPointCharacterSet = YACharacterSet.decimalDigits + YACharacterSet(charactersIn: "Ee.-")

    func scan() -> Float? {
        with {
            skip()
            guard let string = scan(charactersFromSet: YAScanner.floatingPointCharacterSet) else {
                return nil
            }
            return Float(string)
        }
    }

    func scan() -> Double? {
        with {
            skip()

            guard let string = scan(charactersFromSet: YAScanner.floatingPointCharacterSet) else {
                return nil
            }
            return Double(string)
        }
    }

    func scan<T: UnsignedInteger>() -> T? {
        with {
            skip()
            guard let string = scan(charactersFromSet: YACharacterSet.decimalDigits) else {
                return nil
            }
            guard let value = UInt64(string) else {
                return nil
            }
            return T(value)
        }
    }

    // TODO: Replace with regex (this can scan "12345-12345")
    internal static let integerCharacterSet = YACharacterSet.decimalDigits + YACharacterSet(charactersIn: "-")

    func scan<T: SignedInteger>() -> T? {
        with {
            skip()
            guard let string = scan(charactersFromSet: YAScanner.integerCharacterSet) else {
                return nil
            }
            guard let value = Int64(string) else {
                return nil
            }
            return T(value)
        }
    }
}

// MARK: Regular Expressions

public extension YAScanner {
    func scan(_ expression: RegularExpression) -> String? {
        with {
            skip()
            if let match = expression.match(remaining) {
                let range = match.ranges[0]
                let offset = characters.distance(from: range.lowerBound, to: range.upperBound)
                location = characters.index(location, offsetBy: offset)
                return match.strings[0]
            }
            return nil
        }
    }

    func scan(regularExpression string: String) throws -> String? {
        let expression = try RegularExpression(string)
        return scan(expression)
    }
}

// MARK: CGFloat

public extension YAScanner {
    func scan() -> CGFloat? {
        guard let double: Double = scan() else {
            return nil
        }
        return CGFloat(double)
    }
}
