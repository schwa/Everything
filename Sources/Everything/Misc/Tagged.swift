import Foundation

/*

 Use like:

 public enum FooTag {}
 public typealias FooIdentifier = Tagged<FooTag, Value>

 */

public struct Tagged<Kind, Value>: RawRepresentable {
    public var rawValue: Value

    public init(rawValue: Value) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: Value) {
        self.rawValue = rawValue
    }
}

// MARK: -

extension Tagged: Sendable where Value: Sendable {}

extension Tagged: Equatable where Value: Equatable {}

extension Tagged: Hashable where Value: Hashable {}

extension Tagged: Identifiable where Value: Identifiable & Hashable {
    public var id: Value {
        rawValue
    }
}

extension Tagged: Comparable where Value: Comparable {
    public static func < (lhs: Tagged<Kind, Value>, rhs: Tagged<Kind, Value>) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Tagged: Numeric, AdditiveArithmetic where Value: Numeric {
    public typealias Magnitude = Value.Magnitude

    public init?(exactly source: some BinaryInteger) {
        guard let rawValue = RawValue(exactly: source) else {
            return nil
        }
        self.init(rawValue: rawValue)
    }

    public var magnitude: Value.Magnitude {
        rawValue.magnitude
    }

    public static func -= (lhs: inout Tagged<Kind, Value>, rhs: Tagged<Kind, Value>) {
        lhs.rawValue -= rhs.rawValue
    }

    public static func - (lhs: Tagged<Kind, Value>, rhs: Tagged<Kind, Value>) -> Tagged<Kind, Value> {
        .init(lhs.rawValue - rhs.rawValue)
    }

    public static func += (lhs: inout Tagged<Kind, Value>, rhs: Tagged<Kind, Value>) {
        lhs.rawValue += rhs.rawValue
    }

    public static func + (lhs: Tagged<Kind, Value>, rhs: Tagged<Kind, Value>) -> Tagged<Kind, Value> {
        .init(lhs.rawValue + rhs.rawValue)
    }

    public static func * (lhs: Tagged<Kind, Value>, rhs: Tagged<Kind, Value>) -> Tagged<Kind, Value> {
        .init(lhs.rawValue * rhs.rawValue)
    }

    public static func *= (lhs: inout Tagged<Kind, Value>, rhs: Tagged<Kind, Value>) {
        lhs.rawValue *= rhs.rawValue
    }
}

// MARK: -

extension Tagged: SignedNumeric where Value: SignedNumeric {}

// MARK: -

extension Tagged: Strideable where Value: Strideable {
    public typealias Stride = Value.Stride

    public func distance(to other: Tagged<Kind, Value>) -> Value.Stride {
        rawValue.distance(to: other.rawValue)
    }

    public func advanced(by n: Value.Stride) -> Tagged<Kind, Value> {
        Tagged(rawValue: rawValue.advanced(by: n))
    }
}

// MARK: -

extension Tagged: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(Value.self)
    }
}

extension Tagged: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: -

extension Tagged: ExpressibleByUnicodeScalarLiteral where Value: ExpressibleByUnicodeScalarLiteral {
    public typealias UnicodeScalarLiteralType = Value.UnicodeScalarLiteralType

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        rawValue = Value(unicodeScalarLiteral: value)
    }
}

extension Tagged: ExpressibleByExtendedGraphemeClusterLiteral where Value: ExpressibleByExtendedGraphemeClusterLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = Value.ExtendedGraphemeClusterLiteralType

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        rawValue = Value(extendedGraphemeClusterLiteral: value)
    }
}

extension Tagged: ExpressibleByStringLiteral where Value: ExpressibleByStringLiteral {
    public typealias StringLiteralType = Value.StringLiteralType

    public init(stringLiteral value: StringLiteralType) {
        rawValue = Value(stringLiteral: value)
    }
}

extension Tagged: ExpressibleByIntegerLiteral where Value: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Value.IntegerLiteralType

    public init(integerLiteral value: IntegerLiteralType) {
        rawValue = Value(integerLiteral: value)
    }
}

extension Tagged: ExpressibleByFloatLiteral where Value: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Value.FloatLiteralType

    public init(floatLiteral value: FloatLiteralType) {
        rawValue = Value(floatLiteral: value)
    }
}

extension Tagged: ExpressibleByBooleanLiteral where Value: ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Value.BooleanLiteralType

    public init(booleanLiteral value: BooleanLiteralType) {
        rawValue = Value(booleanLiteral: value)
    }
}

// MARK: -

extension Tagged: CustomStringConvertible where Value: CustomStringConvertible {
    public var description: String {
        String(describing: rawValue)
    }
}

extension Tagged: LosslessStringConvertible where RawValue: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let rawValue = RawValue(description) else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
}
