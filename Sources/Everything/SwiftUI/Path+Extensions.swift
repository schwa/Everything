import SwiftUI

public struct PlaceholderShape: Shape {
    public init() {
    }

    public func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addRect(rect)
        }
    }
}

public extension Path {
    mutating func addLine(from: CGPoint, to: CGPoint) {
        move(to: from)
        addLine(to: to)
    }

    mutating func addSCurve(from start: CGPoint, to end: CGPoint) {
        let mid = (end + start) * 0.5

        let c1 = CGPoint(mid.x, start.y)
        let c2 = CGPoint(mid.x, end.y)

        move(to: start)
        addQuadCurve(to: mid, control: c1)
        addQuadCurve(to: end, control: c2)
    }
}

public extension Path {
    init(lines: [(CGPoint, CGPoint)]) {
        self = Path()
        lines.forEach {
            move(to: $0.0)
            addLine(to: $0.1)
        }
    }
}

public extension Path {
    var elements: [Element] {
        var elements: [Element] = []
        forEach { elements.append($0) }
        return elements
    }

    init(elements: [Element]) {
        self = Path { path in
            elements.forEach { element in
                switch element {
                case .move(let point):
                    path.move(to: point)
                case .line(let point):
                    path.addLine(to: point)
                case .quadCurve(let to, let control):
                    path.addQuadCurve(to: to, control: control)
                case .curve(let to, let control1, let control2):
                    path.addCurve(to: to, control1: control1, control2: control2)
                case .closeSubpath:
                    path.closeSubpath()
                }
            }
        }
    }
}

public extension [Path.Element] {
    func path() -> Path {
        Path(elements: self)
    }
}

public extension Path {
    struct Corners: OptionSet {
        public let rawValue: UInt8

        public static let topLeft = Corners(rawValue: 0b0001)
        public static let topRight = Corners(rawValue: 0b0010)
        public static let bottomLeft = Corners(rawValue: 0b0100)
        public static let bottomRight = Corners(rawValue: 0b1000)

        public static let all: Corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    init(roundedRect rect: CGRect, cornerRadius: CGFloat, style: RoundedCornerStyle = .circular, corners: Corners) {
        let elements = Path(roundedRect: rect, cornerRadius: cornerRadius, style: style).elements

        assert(elements.count == 10)

        self = Path(elements: elements
            .enumerated()
            // swiftlint:disable:next closure_body_length
            .map { index, element in
                let corner: Corners
                switch (index, element) {
                case (2, .curve):
                    corner = .bottomRight
                case (4, .curve):
                    corner = .bottomLeft
                case (6, .curve):
                    corner = .topLeft
                case (8, .curve):
                    corner = .topRight
                default:
                    return element
                }
                if !corners.contains(corner) {
                    switch corner {
                    case .topLeft:
                        return .line(to: rect.minXMinY)
                    case .topRight:
                        return .line(to: rect.maxXMinY)
                    case .bottomLeft:
                        return .line(to: rect.minXMaxY)
                    case .bottomRight:
                        return .line(to: rect.maxXMaxY)
                    default:
                        fatalError("Invalid corner.")
                    }
                }
                else {
                    return element
                }
            })
    }
}

public struct Crosshair: Shape {
    public func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: rect.minXMidY)
            path.addLine(to: rect.maxXMidY)
            path.move(to: rect.midXMinY)
            path.addLine(to: rect.midXMaxY)
        }
    }
}

public extension Path {
    mutating func addCrosshair(point: CGPoint, size: CGSize) {
        let size = CGPoint(size)
        move(to: point - size * [-0.5, 0])
        addLine(to: point - size * [0.5, 0])
        move(to: point - size * [0, -0.5])
        addLine(to: point - size * [0, 0.5])
    }
}

public extension Path {
    init(vertices: [CGPoint], closed: Bool = false) {
        self.init()

        move(to: vertices[0])
        for vertex in vertices[1 ..< vertices.count] {
            addLine(to: vertex)
        }
        if closed {
            closeSubpath()
        }
    }
}

public extension Path {
    init(_ rectSize: CGSize) {
        self = Path(CGRect(size: rectSize))
    }
}

