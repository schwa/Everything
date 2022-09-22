// swiftlint:disable file_length

import Foundation

public typealias Value = Any

public struct ParsingError: Swift.Error {
    public let string: String
    public init(_ string: String) {
        self.string = string
    }
}

public struct ParsingOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let disallowConversions = ParsingOptions(rawValue: 0x001)
    public static let disallowFlattening = ParsingOptions(rawValue: 0x010)
    public static let disallowStripping = ParsingOptions(rawValue: 0x100)
}

open class ParsingContext {
    public let scanner: YAScanner
    public let options: ParsingOptions

    public init(scanner: YAScanner, options: ParsingOptions) {
        self.scanner = scanner
        self.options = options
    }
}

public enum Parsing {
    public typealias Converter = (Value) throws -> Value?
    public typealias Action = (Value) throws -> Void
}

// MARK: Protocols

public protocol ContainerElement {
    var subelements: [Element] { get }
}

// MARK: Element

open class Element {
    public init() {}

    open var id: String?
    open var strip = false
    open var flatten = false
    open var converter: Parsing.Converter?
    open var action: Parsing.Action?

    public final func parse(_ string: String, parsingOptions: ParsingOptions = []) throws -> Value? {
        let scanner = YAScanner(string: string)
        let context = ParsingContext(scanner: scanner, options: parsingOptions)
        let value = try parse(context)
        return value
    }

    func process(_ context: ParsingContext) throws -> Value? {
        guard let value = try parse(context) else {
            return nil
        }
        if let converter, context.options.contains(.disallowConversions) == false {
            if let value = try converter(value) {
                return value
            }
            else {
                throw ParsingError("Failed to convert")
            }
        }

        try action?(value)

        return value
    }

    // swiftlint:disable:next unavailable_function
    open func parse(_: ParsingContext) throws -> Value? {
        preconditionFailure("Implement in subclass")
    }
}

extension Element: CustomStringConvertible {
    public var description: String {
        "\(type(of: self))(id: \(String(describing: id)))"
    }
}

public extension Element {
    func setID(_ id: String) -> Element {
        self.id = id
        return self
    }

    func makeStripped() -> Element {
        strip = true
        return self
    }

    func makeFlattened() -> Element {
        flatten = true
        return self
    }

    func makeConverted(_ converter: @escaping Parsing.Converter) -> Element {
        self.converter = converter
        return self
    }

    func withAction(_ action: @escaping Parsing.Action) -> Element {
        self.action = action
        return self
    }
}

// MARK: Literal

open class Literal: Element {
    public let value: String

    public init(_ value: String) {
        self.value = value
        super.init()
    }

    override open func parse(_ context: ParsingContext) throws -> Value? {
        guard context.scanner.scan(string: value) == true else {
            return .none
        }
        return value
    }
}

// MARK: Literal

open class Pattern: Element {
    open var expression: RegularExpression!

    public init(_ pattern: String) throws {
        super.init()
        expression = try RegularExpression(pattern)
    }

    override open func parse(_ context: ParsingContext) throws -> Value? {
        guard let value = context.scanner.scan(expression) else {
            return .none
        }

        return value
    }
}

// MARK: Value

open class ScannedValue: Element {
    public let scan: (_ scanner: YAScanner) throws -> Value?

    public init(scan: @escaping ((_ scanner: YAScanner) throws -> Value?)) {
        self.scan = scan
    }

    override open func parse(_ context: ParsingContext) throws -> Value? {
        guard let value = try scan(context.scanner) else {
            return nil
        }
        return value
    }
}

public func DoubleValue() -> ScannedValue {
    ScannedValue { scanner in
        let result: Double? = scanner.scan()
        return result
    }
}

public func IntValue() -> ScannedValue {
    ScannedValue { scanner in
        let result: Int? = scanner.scan()
        return result
    }
}

public func identifierValue() -> ScannedValue {
    ScannedValue { scanner in
        let result = try scanner.scan(regularExpression: "^[A-Za-z_]+")
        return result
    }
}

public func patternValue(_ pattern: String) -> ScannedValue {
    ScannedValue { scanner in
        let result = try scanner.scan(regularExpression: pattern)
        return result
    }
}

// MARK: Range

open class RangeOf: Element {
    public let min: Int?
    public let max: Int?
    public let subelement: Element

    public init(min: Int?, max: Int?, subelement: Element) {
        self.min = min
        self.max = max
        self.subelement = subelement
        super.init()
    }

    override open func parse(_ context: ParsingContext) throws -> Value? {
        var compoundResult: [Value] = []

        loop: while true {
            if let max, compoundResult.count == max {
                break loop
            }

            guard let result = try subelement.process(context) else {
                break loop
            }
            compoundResult.append(result)
        }

        if let min, compoundResult.count < min {
            throw ParsingError("\(self): Could not scan enough. Expected \(min), got: \(compoundResult.count). Remaining: \"\(context.scanner.remaining)\"")
        }

        if flatten == true, context.options.contains(.disallowFlattening) == false {
            if compoundResult.count == 1 {
                return compoundResult[0]
            }
            else if compoundResult.isEmpty {
                return nil
            }
            else {
                throw ParsingError("Could not flatten: \(compoundResult)")
            }
        }

        return compoundResult
    }
}

extension RangeOf: ContainerElement {
    public var subelements: [Element] {
        [subelement]
    }
}

// MARK: -

public func zeroOrOne(_ subelement: Element) -> RangeOf {
    let rangeOf = RangeOf(min: 0, max: 1, subelement: subelement)
    rangeOf.flatten = true
    return rangeOf
}

public func oneOrMore(_ subelement: Element) -> RangeOf {
    let rangeOf = RangeOf(min: 1, max: nil, subelement: subelement)
    return rangeOf
}

public func zeroOrMore(_ subelement: Element) -> RangeOf {
    let rangeOf = RangeOf(min: 0, max: nil, subelement: subelement)
    return rangeOf
}

// MARK: OneOf

open class OneOf: Element {
    public let subelements: [Element]

    public init(_ subelements: [Element]) {
        self.subelements = subelements
        super.init()
    }

    override open func parse(_ context: ParsingContext) throws -> Value? {
        for element in subelements {
            let result = try element.process(context)
            if result != nil {
                return result
            }
        }
        return .none
    }
}

extension OneOf: ContainerElement {}

// MARK: Compound

open class Compound: Element {
    public let subelements: [Element]

    public init(_ subelements: [Element]) {
        assert(!subelements.isEmpty)
        self.subelements = subelements
        super.init()
    }

    override open func parse(_ context: ParsingContext) throws -> Value? {
        var compoundResult: [Value] = []
        loop: for element in subelements {
            if context.scanner.atEnd {
                break
            }
            guard let result = try element.process(context) else {
                break loop
            }

            // TODO:
            if element.strip == false, context.options.contains(.disallowStripping) == false {
                compoundResult.append(result)
            }
        }

        var result: Value?

        if compoundResult.isEmpty {
            result = .none
        }
        else if flatten == true, context.options.contains(.disallowFlattening) == false {
            if compoundResult.count == 1 {
                result = compoundResult[0]
            }
            else {
                throw ParsingError("couldn't flatten: \(String(describing: id))")
            }
        }
        else {
            result = compoundResult
        }

        if let value = result {
            return value
        }

        return result
    }
}

extension Compound: ContainerElement {}

// MARK: AtEnd

open class AtEnd: Element {
    override open func parse(_ context: ParsingContext) throws -> Value? {
        if context.scanner.atEnd {
            return nil
        }
        else {
            throw ParsingError("Not at end, remaining: \"\(context.scanner.remaining)\"")
        }
    }
}

public let atEnd = AtEnd()

// MARK: Delimited List

open class DelimitedList: Element {
    let subelement: Element
    let min: Int
    let max: Int
    let delimiter: String

    public init(subelement: Element, min: Int = 0, max: Int = Int.max, delimiter: String = ",") {
        self.subelement = subelement
        self.min = min
        self.max = max
        self.delimiter = delimiter
    }

    override open func parse(_ context: ParsingContext) throws -> Value? {
        try context.scanner.with {
            var values: [Value] = []

            guard let initialValue = try subelement.process(context) else {
                return nil
            }

            values.append(initialValue)

            while true {
                if values.count > max {
                    return nil
                }

                if context.scanner.scan(string: delimiter) == false {
                    break
                }

                guard let value = try subelement.process(context) else {
                    return nil
                }

                values.append(value)
            }

            if values.count < min {
                return nil
            }

            return values
        }
    }
}

// MARK: Covenience operators

public extension Element {
    static func | (lhs: Element, rhs: Element) -> OneOf {
        let result: OneOf
        if let lhs = lhs as? OneOf, let rhs = rhs as? OneOf {
            result = OneOf(lhs.subelements + rhs.subelements)
        }
        else if let lhs = lhs as? OneOf {
            result = OneOf(lhs.subelements + [rhs])
        }
        else if let rhs = rhs as? OneOf {
            result = OneOf([lhs] + rhs.subelements)
        }
        else {
            result = OneOf([lhs, rhs])
        }
        return result
    }

    static func + (lhs: Element, rhs: Element) -> Element {
        let result: Compound
        if let lhs = lhs as? Compound, let rhs = rhs as? Compound {
            result = Compound(lhs.subelements + rhs.subelements)
        }
        else if let lhs = lhs as? Compound {
            result = Compound(lhs.subelements + [rhs])
        }
        else if let rhs = rhs as? Compound {
            result = Compound([lhs] + rhs.subelements)
        }
        else {
            result = Compound([lhs, rhs])
        }
        return result
    }
}
