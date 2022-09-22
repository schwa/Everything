import Foundation

public protocol Locking {
    mutating func lock()
    mutating func unlock()
}

// MARK: -

public extension Locking {
    mutating func with<R>(closure: () throws -> R) rethrows -> R {
        lock()
        defer {
            unlock()
        }
        return try closure()
    }
}

// MARK: -

extension NSLock: Locking {}

extension NSRecursiveLock: Locking {}

public func synchronized<R>(object: AnyObject, closure: () throws -> R) rethrows -> R {
    objc_sync_enter(object)
    defer {
        let result = objc_sync_exit(object)
        guard Int(result) == OBJC_SYNC_SUCCESS else {
            unimplemented()
        }
    }
    return try closure()
}
