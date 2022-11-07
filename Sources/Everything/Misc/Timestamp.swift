import Foundation

/**
 *  A wrapper around CFAbsoluteTime
 *
 *  CFAbsoluteTime is just typealias for a Double. By wrapping it in a struct we're able to extend it.
 */
public struct Timestamp {
    public let absoluteTime: CFAbsoluteTime

    public init() {
        absoluteTime = CFAbsoluteTimeGetCurrent()
    }

    public init(absoluteTime: CFAbsoluteTime) {
        self.absoluteTime = absoluteTime
    }
}

// MARK: -

extension Timestamp: Equatable {
    public static func == (lhs: Timestamp, rhs: Timestamp) -> Bool {
        lhs.absoluteTime == rhs.absoluteTime
    }
}

// MARK: -

extension Timestamp: Comparable {
    public static func < (lhs: Timestamp, rhs: Timestamp) -> Bool {
        lhs.absoluteTime < rhs.absoluteTime
    }
}

// MARK: -

extension Timestamp: Hashable {
    public func hash(into hasher: inout Hasher) {
        absoluteTime.hash(into: &hasher)
    }
}

// MARK: -

extension Timestamp: CustomStringConvertible {
    public var description: String {
        String(absoluteTime)
    }
}
