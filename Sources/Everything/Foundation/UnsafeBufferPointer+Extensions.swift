import Foundation

public extension UnsafeBufferPointer {
    init() {
        self.init(start: nil, count: 0)
    }

    init(start: UnsafePointer<Element>, byteCount: Int) {
        precondition(byteCount % UnsafeBufferPointer<Element>.elementSize == 0)
        self.init(start: start, count: byteCount / UnsafeBufferPointer<Element>.elementSize)
    }

    func withMemoryRebound<T, Result>(to _: T.Type, capacity count: Int, _ body: (UnsafeBufferPointer<T>) throws -> Result) rethrows -> Result {
        guard let baseAddress = baseAddress else {
            // If base address is nil just return an empty buffer
            let buffer = UnsafeBufferPointer<T>()
            return try body(buffer)
        }

        precondition(((self.count * UnsafeBufferPointer<Element>.elementSize) % count) == 0)

        return try baseAddress.withMemoryRebound(to: T.self, capacity: count) { (pointer: UnsafePointer<T>) -> Result in
            let buffer = UnsafeBufferPointer<T>(start: pointer, count: count)
            return try body(buffer)
        }
    }

    func withMemoryRebound<T, Result>(_ body: (UnsafeBufferPointer<T>) throws -> Result) rethrows -> Result {
        let count = (self.count * UnsafeBufferPointer<Element>.elementSize) / UnsafeBufferPointer<T>.elementSize
        return try withMemoryRebound(to: T.self, capacity: count, body)
    }
}

public extension UnsafeMutableBufferPointer {
    func toUnsafeBufferPointer() -> UnsafeBufferPointer<Element> {
        UnsafeBufferPointer<Element>(start: baseAddress, count: count)
    }
}
