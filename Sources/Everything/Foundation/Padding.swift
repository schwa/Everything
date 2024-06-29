import Foundation

public enum PaddedPosition {
    case start
    case end
}

public extension Array {
    func padded(with element: Element, count: Int, position: PaddedPosition) -> Self {
        guard self.count < count else {
            return self
        }
        var copy = self

        switch position {
        case .start:
            copy = repeatElement(element, count: count - self.count) + copy

        case .end:
            copy += repeatElement(element, count: count - self.count)
        }
        return copy
    }
}

public extension String {
    func padded(with element: Element, count: Int, position: PaddedPosition) -> Self {
        guard self.count < count else {
            return self
        }
        var copy = self

        switch position {
        case .start:
            copy = repeatElement(element, count: count - self.count) + copy

        case .end:
            copy += repeatElement(element, count: count - self.count)
        }
        return copy
    }
}
