import Foundation

public enum AnyCodingKey: CodingKey, CustomStringConvertible {
    case string(String)
    case int(Int)

    public init?(stringValue: String) {
        self = .string(stringValue)
    }

    public init?(intValue: Int) {
        self = .int(intValue)
    }

    public var stringValue: String {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return "#\(value)"
        }
    }

    public var intValue: Int? {
        if case let .int(value) = self {
            return value
        }
        else {
            fatalError("TODO")
        }
    }

    public init<K>(key: K) where K: CodingKey {
        if let value = key.intValue {
            self = .int(value)
        }
        else {
            self = .string(key.stringValue)
        }
    }

    public var description: String {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return "#\(value)"
        }
    }
}

extension AnyCodingKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}
