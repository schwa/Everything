import os.log

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public struct LolUID: Hashable {
    static let lock = OSAllocatedUnfairLock(uncheckedState: 0)

    static func nextID() -> Int {
        lock.withLock { nextID in
            let id = nextID
            nextID += 1
            return id
        }
    }

    public let id: Int

    public init() {
        id = LolUID.nextID()
    }
}

@available(*, deprecated, message: "Use OSAllocatedUnfairLock()")
public extension UnsafeMutablePointer where Pointee == os_unfair_lock {
    init() {
        self = UnsafeMutablePointer.allocate(capacity: 1)
        initialize(to: os_unfair_lock())
    }

    func lock() {
        os_unfair_lock_lock(self)
    }

    func unlock() {
        os_unfair_lock_unlock(self)
    }

    func withLock<R>(_ transaction: () throws -> R) rethrows -> R {
        lock()
        defer {
            unlock()
        }
        return try transaction()
    }
}
