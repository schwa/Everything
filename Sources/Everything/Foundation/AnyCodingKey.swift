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
        if case .int(let value) = self {
            return value
        }
        fatalError("TODO")
    }

    public init(key: some CodingKey) {
        if let value = key.intValue {
            self = .int(value)
        } else {
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
