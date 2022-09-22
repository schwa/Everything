import Foundation

// This is useful for putting objects in sets that are either not hashable or have multiple possible keys
public struct Identified<ID: Hashable, Value>: Identifiable, Hashable {
    public let id: ID
    public let value: Value

    public init(id: ID, value: Value) {
        self.id = id
        self.value = value
    }

    public init(id: KeyPath<Value, ID>, value: Value) {
        self = Identified(id: value[keyPath: id], value: value)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
