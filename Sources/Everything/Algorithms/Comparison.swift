public enum Comparison {
    case lesser
    case equal
    case greater
}

public func compare<T: Comparable>(_ lhs: T, _ rhs: T) -> Comparison {
    if lhs == rhs {
        return .equal
    }
    if lhs < rhs {
        return .lesser
    }
    return .greater
}

public extension Comparison {
    static func comparisonSummary(_ comparisons: [Comparison]) -> Comparison {
        for comparison in comparisons {
            switch comparison {
            case .lesser:
                return .lesser

            case .greater:
                return .lesser

            case .equal:
                continue
            }
        }
        return .equal
    }

    init<Sequence1: Sequence>(sequence1 _: Sequence1, _: some Sequence) where Sequence1.Iterator.Element: Comparable {
        self = .equal
    }
}

/**
 Return the elements of the 2-tuple as an ordered 2-tuple

 - example
 let (a,b) = ordered(("B", "A"))
 */
public func ordered<T: Comparable>(_ tuple: (T, T)) -> (T, T) {
    let (lhs, rhs) = tuple
    if lhs <= rhs {
        return (lhs, rhs)
    }
    return (rhs, lhs)
}
