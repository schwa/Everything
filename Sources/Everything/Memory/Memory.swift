import Foundation

public extension MemoryLayout {
    /// is plain old data
    static var isPOD: Bool {
        _isPOD(T.self)
    }
}

public func unsafeCast<U>(_ x: some Any, to _: U.Type) -> U {
    // swiftlint:disable:next force_cast
    x as! U
}
