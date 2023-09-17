import Foundation

// JSONPath         Description
// $                the root object/element
// @                the current object/element
// . or []          child operator
// ..               recursive descent. JSONPath borrows this syntax from E4X.
// *                wildcard. All objects/elements regardless their names.
// []               subscript operator. XPath uses it to iterate over element collections and for predicates. In Javascript and JSON it is the native array operator.
// [,]              Union operator in XPath results in a combination of node sets. JSONPath allows alternate names or array indices as a set.
// [start:end:step] array slice operator borrowed from ES4.
// ?()              applies a filter (script) expression.
// ()               script expression, using the underlying script engine.

@available(*, deprecated, message: "Deprecated. Removing.")
open class JSONPath {
    public enum Error: Swift.Error {
        case unknown
        case syntaxError(String)
        case typeMismatch(String)
        case unimplemented
    }

    public let source: String
    open private(set) var evaluators: [Evaluator]?

    public init(_ source: String, compile: Bool = false) throws {
        self.source = source
        if compile {
            try self.compile()
        }
    }

    open func compile() throws {
        guard let value = try parser.parse(source) else {
            throw Error.syntaxError("¯\\(°_o)/¯")
        }
        guard let values = value as? [Any] else {
            preconditionFailure()
        }
        evaluators = values.map {
            $0 as! Evaluator
        }
    }

    open func evaluate(_ parameter: Any) throws -> Any? {
        if evaluators == nil {
            try compile()
        }
        guard let evaluators else {
            preconditionFailure()
        }
        var current: Any = parameter
        for evaluator in evaluators {
            guard let next = try evaluator.evaluate(current) else {
                return nil
            }
            current = next
        }
        return current
    }

    open func dumpParse() throws {
        let value = try parser.parse(source, parsingOptions: [.disallowConversions, .disallowFlattening /* , .DisallowStripping */ ])
        print(value as Any)
    }
}

// MARK: -

@available(*, deprecated, message: "Deprecated. Removing.")
public extension JSONPath {
    func evaluate<T>(_ parameter: AnyObject) throws -> [T] {
        // TODO: what about other SequenceTypes
        let result = try evaluate(parameter)
        guard let values = result as? [AnyObject] else {
            throw JSONPath.Error.typeMismatch("Expected [Any], got \(type(of: result)) (#1)")
        }
        return try values.map {
            guard let value = $0 as? T else {
                throw JSONPath.Error.typeMismatch("Expected \(T.self), got \(type(of: result)) (#2)")
            }
            return value
        }
    }
}

// MARK: -

@available(*, deprecated, message: "Deprecated. Removing.")
open class Evaluator {
    let type: String
    let parameter: Any
    let evaluate: (Any) throws -> Any?

    init(type: String, parameter: Any, evaluate: @escaping (Any) throws -> Any?) {
        self.type = type
        self.parameter = parameter
        self.evaluate = evaluate
    }
}

@available(*, deprecated, message: "Deprecated. Removing.")
extension Evaluator: CustomStringConvertible {
    public var description: String {
        "Evaluator(\(type), \(parameter))"
    }
}

// MARK: -

// swiftlint:disable:next closure_body_length
@available(*, deprecated, message: "Deprecated. Removing.")
private let parser: Element = {
    let DOLLAR = Literal("$").makeStripped()
    let LBRACKET = Literal("[").makeStripped()
    let RBRACKET = Literal("]").makeStripped()
    let SINGLE_QUOTE = Literal("'").makeStripped()
    let COMMA = Literal(",").makeStripped()
    let COLON = Literal(":").makeStripped()
    let DOT = Literal(".").makeStripped()

    let wildcardSelector = Literal("*").makeConverted { parameter in
        Evaluator(type: "wildcard", parameter: parameter) { value in
            try wildcard(value as AnyObject)
        }
    }

    let nameSelector = identifierValue().makeConverted { parameter in
        Evaluator(type: "name", parameter: parameter) { value in
            let key = parameter as! String
            return try lookup(key, value: value as AnyObject)
        }
    }

    let indexedSelector = IntValue().makeConverted { parameter in
        Evaluator(type: "index", parameter: parameter) { value in
            let index = parameter as! Int
            return try lookup(index, value: value as AnyObject)
        }
    }

    let namesListSelector = DelimitedList(subelement: identifierValue(), min: 2).makeConverted { parameter in
        Evaluator(type: "names list", parameter: parameter) { value in
            let keys = (parameter as! [Any]).map { $0 as! String }
            return try lookup(keys, value: value as AnyObject)
        }
    }

    let rootOperator = Literal("$").makeConverted { _ in
        Evaluator(type: "root", parameter: ()) { value in
            value
        }
    }
    let dotOperator = Literal(".").makeStripped()

    let bracketSelector = (namesListSelector | nameSelector | indexedSelector | wildcardSelector).makeFlattened()

    let dotPathElement = (dotOperator + (nameSelector | indexedSelector | wildcardSelector).makeFlattened()).makeFlattened()

    let quotedNameElement = (SINGLE_QUOTE + nameSelector + SINGLE_QUOTE)

    let bracketPathElement = (LBRACKET + bracketSelector + RBRACKET).makeFlattened()

    let pathElement = (dotPathElement | bracketPathElement)

    let path = (rootOperator + zeroOrMore(pathElement)).makeFlattened()

    let parser = (path + atEnd).makeFlattened()

    return parser
}()

// MARK: -

@available(*, deprecated, message: "Deprecated. Removing.")
private func wildcard(_ value: AnyObject) throws -> AnyObject? {
    switch value {
    case let dictionary as [String: AnyObject]:
        return Array(dictionary.values) as AnyObject?
    case let array as [AnyObject]:
        return array as AnyObject?
    default:
        return value
    }
}

@available(*, deprecated, message: "Deprecated. Removing.")
private func lookup(_ key: String, value: AnyObject) throws -> AnyObject? {
    switch value {
    case let dictionary as [String: AnyObject]:
        return try lookup(key, value: dictionary)
    case let array as [AnyObject]:
        return try lookup(key, value: array)
    default:
        throw JSONPath.Error.unimplemented
    }
}

@available(*, deprecated, message: "Deprecated. Removing.")
private func lookup(_ keys: [String], value: AnyObject) throws -> AnyObject? {
    let values = try keys.map { (key: String) -> AnyObject in
        guard let value = try lookup(key, value: value) else {
            throw JSONPath.Error.unknown
        }
        return value
    }
    return values as AnyObject?
}

@available(*, deprecated, message: "Deprecated. Removing.")
private func lookup(_ key: String, value: [String: AnyObject]) throws -> AnyObject? {
    value[key]
}

@available(*, deprecated, message: "Deprecated. Removing.")
private func lookup(_ key: String, value: [AnyObject]) throws -> AnyObject? {
    let values: [AnyObject] = try value.map { value in
        guard let result = try lookup(key, value: value) else {
            throw JSONPath.Error.unknown
        }
        return result
    }
    return values as AnyObject?
}

@available(*, deprecated, message: "Deprecated. Removing.")
private func lookup(_ index: Int, value: AnyObject) throws -> AnyObject? {
    switch value {
    case let array as [AnyObject]:
        return array[index]
    default:
        throw JSONPath.Error.unimplemented
    }
}
