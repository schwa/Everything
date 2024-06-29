import Foundation
import os

public protocol CacheProtocol {
    associatedtype Key: Hashable
    associatedtype Value

    func contains(key: Key) -> Bool
    func get(key: Key) throws -> Value?
    func set(key: Key, value: Value) throws
    func set(key: Key, value: Value, cost: Int?) throws
    func remove(key: Key)
}

enum CacheError: Swift.Error {
    case typeMismatch
}

/// A class that wraps NSCache and allows you to use any types as keys/values.
public final class Cache <Key: Hashable, Value>: Identifiable, CacheProtocol {
    private class KeyBox <Base>: NSObject where Base: Hashable {
        let base: Base

        init(_ base: Base) {
            self.base = base
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard let object = object as? Self else {
                return false
            }
            return self.base == object.base
        }

        override var hash: Int {
            base.hashValue
        }
    }

    private class ValueBox <Base> {
        let base: Base

        init(_ base: Base) {
            self.base = base
        }
    }

    private enum Storage {
        case nsCache(NSCache <KeyBox<Key>, ValueBox<Any>>)
        case anyCache(Cache<AnyHashable, Any>)
    }

    public var id: TrivialID
    private var storage: Storage
    private var logger: Logger? = Logger()

    public init() {
        id = .init(scope: "cache")
        storage = .nsCache(.init())
        logger?.debug("Creating fresh cache: '\(self.id)'.")
    }

    public init(base: Cache<AnyHashable, Any>) {
        id = .init(scope: "cache")
        storage = .anyCache(base)
        logger?.debug("Creating child cache: '\(self.id)' on '\(base.id)'.")
    }

    public func contains(key: Key) -> Bool {
        fatalError()
    }

    public func get(key: Key) throws -> Value? {
        let value: Any?
        switch storage {
        case .nsCache(let nsCache):
            guard let box = nsCache.object(forKey: KeyBox(key)) else {
                return nil
            }
            value = box.base as? Value

        case .anyCache(let cache):
            value = try cache.get(key: key)
        }
        guard let value else {
            return nil
        }
        return try cast(value, as: Value.self)
    }

    public func set(key: Key, value: Value, cost: Int? = nil) {
        switch storage {
        case .nsCache(let nsCache):
            let key = KeyBox(key)
            let value = ValueBox<Any>(value)
            if let cost {
                nsCache.setObject(value, forKey: key, cost: cost)
            } else {
                nsCache.setObject(value, forKey: key)
            }

        case .anyCache(let cache):
            cache.set(key: key, value: value, cost: cost)
        }
    }

    public func remove(key: Key) {
        switch storage {
        case .nsCache(let nsCache):
            let key = KeyBox(key)
            nsCache.removeObject(forKey: key)

        case .anyCache(let cache):
            cache.remove(key: key)
        }
    }
}

// MARK: -

public extension CacheProtocol {
    func set(key: Key, value: Value) throws {
        try set(key: key, value: value, cost: nil)
    }
}

public extension CacheProtocol {
    subscript(key: Key)  -> Value? {
        get {
            try! get(key: key)
        }
        set {
            if let newValue {
                try! set(key: key, value: newValue)
            } else {
                remove(key: key)
            }
        }
    }
}

public extension CacheProtocol {
    func get(key: Key, factory: () throws -> Value) throws -> Value {
        if let value: Value = try get(key: key) {
            return value
        }
        let value = try factory()
        try set(key: key, value: value)
        return value
    }

    func get(key: Key, factory: () throws -> (Value, Int)) throws -> Value {
        if let value: Value = try get(key: key) {
            return value
        }
        let (value, cost) = try factory()
        try set(key: key, value: value, cost: cost)
        return value
    }
}

public extension CacheProtocol {
    func get(key: Key, factory: () async throws -> Value) async throws -> Value {
        if let value: Value = try get(key: key) {
            return value
        }
        let value = try await factory()
        try set(key: key, value: value)
        return value
    }

    func get(key: Key, factory: () async throws -> (Value, Int)) async throws -> Value {
        if let value: Value = try get(key: key) {
            return value
        }
        let (value, cost) = try await factory()
        try set(key: key, value: value, cost: cost)
        return value
    }
}

public extension Cache where Key == AnyHashable, Value == Any {
    func `as`<V>(valueType: V.Type) -> Cache<Key, V> {
        Cache<Key, V>(base: self)
    }

    func `as`<K, V>(keyType: K.Type, valueType: V.Type) -> Cache<K, V> where K: Hashable {
        Cache<K, V>(base: self)
    }
}
