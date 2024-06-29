import os.log

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
@available(*, deprecated, message: "Use TrivialID")
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
        id = Self.nextID()
    }
}
