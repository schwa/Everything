import Foundation

public extension Array {
    func extended(with element: Element, count: Int) -> Self {
        self + repeatElement(element, count: count - self.count)
    }

    func extended(with element: Element?, count: Int) -> [Element?] {
        self + repeatElement(element, count: count - self.count)
    }
}

public func inverseLerp(from lowerBound: Float, to upperBound: Float, by value: Float) -> Float {
    (value - lowerBound) / (upperBound - lowerBound)
}
