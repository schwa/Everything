import Foundation

public protocol Custom2TupleConvertable {
    associatedtype Element
    typealias Tuple = (Element, Element)

    init(tuple: Tuple)
    var tuple: Tuple { get }
}

public extension Custom2TupleConvertable {
    func map(_ transform: (Element) -> Element) -> Self {
        Self(tuple: (transform(tuple.0), transform(tuple.1)))
    }
}

public func floor<T>(_ value: T) -> T where T: Custom2TupleConvertable, T.Element: FloatingPoint {
    value.map(floor)
}

public func ceil<T>(_ value: T) -> T where T: Custom2TupleConvertable, T.Element: FloatingPoint {
    value.map(ceil)
}

public func round<T>(_ value: T) -> T where T: Custom2TupleConvertable, T.Element: FloatingPoint {
    value.map(round)
}

public func min<T>(_ lhs: T, _ rhs: T) -> T where T: Custom2TupleConvertable, T.Element: Comparable {
    let lhs = lhs.tuple
    let rhs = rhs.tuple
    return T(tuple: (min(lhs.0, rhs.0), y: min(lhs.1, rhs.1)))
}

public func max<T>(_ lhs: T, _ rhs: T) -> T where T: Custom2TupleConvertable, T.Element: Comparable {
    let lhs = lhs.tuple
    let rhs = rhs.tuple
    return T(tuple: (max(lhs.0, rhs.0), y: max(lhs.1, rhs.1)))
}
