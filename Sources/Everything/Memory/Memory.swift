import Foundation

public extension MemoryLayout {
    /// is plain old data
    static var isPOD: Bool {
        _isPOD(T.self)
    }
}

public func unsafeCast<T, U>(_ x: T, to _: U.Type) -> U {
    // swiftlint:disable:next force_cast
    x as! U
}
