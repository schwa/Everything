import CoreGraphics

extension CGPoint: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CGFloat...) {
        assert(elements.count == 2)
        self = CGPoint(x: elements[0], y: elements[1])
    }
}

extension CGSize: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CGFloat...) {
        assert(elements.count == 2)
        self = CGSize(width: elements[0], height: elements[1])
    }
}

extension CGPoint: Custom2TupleConvertable {
    public init(tuple: (CGFloat, CGFloat)) {
        self.init(x: tuple.0, y: tuple.1)
    }

    public var tuple: (CGFloat, CGFloat) {
        (x, y)
    }
}

extension CGSize: Custom2TupleConvertable {
    public init(tuple: (CGFloat, CGFloat)) {
        self.init(width: tuple.0, height: tuple.1)
    }

    public var tuple: (CGFloat, CGFloat) {
        (width, height)
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        x.hash(into: &hasher)
        y.hash(into: &hasher)
    }
}

extension CGSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        width.hash(into: &hasher)
        height.hash(into: &hasher)
    }
}

// MARK: CGRect

public extension CGRect {
    init(width: CGFloat, height: CGFloat) {
        self.init(x: 0, y: 0, width: width, height: height)
    }

    init(minX: CGFloat, minY: CGFloat, maxX: CGFloat, maxY: CGFloat) {
        self.init(x: min(minX, maxX), y: min(minY, maxY), width: abs(maxX - minX), height: abs(maxY - minY))
    }

    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5, width: size.width, height: size.height)
    }

    init(center: CGPoint, radius: CGFloat) {
        self.init(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
    }

    init(points: (CGPoint, CGPoint)) {
        let r0 = Self(center: points.0, size: CGSize.zero)
        let r1 = Self(center: points.1, size: CGSize.zero)
        self = r0.union(r1)
    }
}

extension CGRect: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CGFloat...) {
        assert(elements.count == 4)
        self = CGRect(x: elements[0], y: elements[1], width: elements[2], height: elements[3])
    }
}

public extension CGRect {
    // Note: Rename "Position" to something else?
    enum Position {
        case minXMinY
        case minXMaxY
        case maxXMinY
        case maxXMaxY

        case minXMidY
        case maxXMidY

        case midXMinY
        case midXMaxY

        case midXMidY
    }

    func point(for position: Position) -> CGPoint {
        switch position {
        case .minXMinY:
            return minXMinY
        case .minXMaxY:
            return minXMaxY
        case .maxXMinY:
            return maxXMinY
        case .maxXMaxY:
            return maxXMaxY
        case .minXMidY:
            return minXMidY
        case .maxXMidY:
            return maxXMidY
        case .midXMinY:
            return midXMinY
        case .midXMaxY:
            return midXMaxY
        case .midXMidY:
            return midXMidY
        }
    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        origin.hash(into: &hasher)
        size.hash(into: &hasher)
    }
}

// MARK: -

public extension CGPoint {
    static func random<T>(in rect: CGRect, using generator: inout T) -> Self where T: RandomNumberGenerator {
        let x = CGFloat.random(in: rect.minX ... rect.maxX)
        let y = CGFloat.random(in: rect.minY ... rect.maxY)
        return CGPoint(x: x, y: y)
    }

    static func random(in rect: CGRect) -> Self {
        var rng = SystemRandomNumberGenerator()
        return CGPoint.random(in: rect, using: &rng)
    }
}

public extension CGPoint {
    static func random() -> CGPoint {
        CGPoint(x: CGFloat.random(in: 0 ... 1), y: CGFloat.random(in: 0 ... 1))
    }

    static func random(x: ClosedRange<CGFloat>, y: ClosedRange<CGFloat>) -> CGPoint {
        CGPoint(x: CGFloat.random(in: x), y: CGFloat.random(in: y))
    }
}

public extension CGPoint {
    static func += (lhs: inout CGPoint, rhs: CGSize) {
        lhs += CGPoint(rhs)
    }
}
