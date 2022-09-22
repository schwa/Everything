import Foundation
import os

@propertyWrapper
public struct Atomic<Value> where Value: Sendable {
    var lock: OSAllocatedUnfairLock<Value>

    public init(wrappedValue: Value) {
        lock = .init(initialState: wrappedValue)
    }

    public var wrappedValue: Value {
        get {
            lock.withLock { value in
                value
            }
        }
        set {
            lock.withLock { value in
                value = newValue
            }
        }
    }
}

@propertyWrapper
public struct UncheckedAtomic<Value> {
    var lock: OSAllocatedUnfairLock<()>
    var _wrappedValue: Value

    public init(wrappedValue: Value) {
        lock = .init()
        _wrappedValue = wrappedValue
    }

    public var wrappedValue: Value {
        get {
            lock.withLockUnchecked {
                _wrappedValue
            }
        }
        set {
            lock.withLockUnchecked {
                _wrappedValue = newValue
            }
        }
    }
}
