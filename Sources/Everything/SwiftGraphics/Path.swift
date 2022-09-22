import SwiftUI

// #if os(macOS)
//    import AppKit
// #endif
// import CoreGraphics
//
// public struct Path {
//    public enum PathElement {
//        case move(CGPoint)
//        case line(CGPoint)
//        case curve(BezierCurve)
//        case path(Path)
//        case close
//    }
//
//    public private(set) var elements: [PathElement] = []
//
//    public private(set) var currentPoint: CGPoint?
//
//    public init() {
//    }
//
//    @discardableResult public mutating func move(_ point: CGPoint) -> Path {
//        currentPoint = point
//        elements.append(.move(point))
//        return self
//    }
//
//    @discardableResult public mutating func add(line point: CGPoint) -> Path {
//        currentPoint = point
//        elements.append(.line(point))
//        return self
//    }
//
//    @discardableResult public mutating func add(curve: BezierCurve) -> Path {
//        currentPoint = curve.end
//        elements.append(.curve(curve))
//        return self
//    }
//
//    @discardableResult public mutating func add(path: Path) -> Path {
//        currentPoint = path.currentPoint
//        elements.append(.path(path))
//        return self
//    }
//
//    @discardableResult public mutating func close() -> Path {
//        elements.append(.close)
//        return self
//    }
//
//    public func closed() -> Path {
//        var copy = self
//        copy.close()
//        return copy
//    }
// }

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

    @discardableResult
    mutating func add(curve: BezierCurve) -> Path {
        switch curve.order {
        case .cubic:
            addCurve(to: curve.end, control1: curve.controls[0], control2: curve.controls[1])
        case .quadratic:
            addQuadCurve(to: curve.end, control: curve.controls[0])
        default:
            assertionFailure("Unsupported bezier curve order.")
        }
        return self
    }
}

// public extension Path {
//    func toCGPath() -> CGPath {
//        let path = CGMutablePath()
//        for element in elements {
//            switch element {
//            case .move(let point):
//                path.move(to: point)
//            case .line(let point):
//                path.addLine(to: point)
//            case .curve(let curve):
//                switch curve.order {
//                case .cubic:
//                    path.addCurve(to: curve.end, control1: curve.controls[0], control2: curve.controls[1])
//                case .quadratic:
//                    path.addQuadCurve(to: curve.end, control: curve.controls[0])
//                default:
//                    assertionFailure("Unsupported bezier curve order.")
//                }
//            case .path(let newPath):
//                path.addPath(newPath.toCGPath())
//            case .close:
//                path.closeSubpath()
//            }
//        }
//        return path
//    }
// }
//
// #if os(macOS)
//    public extension Path {
//        func toBezierPath() -> NSBezierPath {
//            let path = NSBezierPath()
//            for element in elements {
//                switch element {
//                case .move(let point):
//                    path.move(to: point)
//                case .line(let point):
//                    path.line(to: point)
//                case .curve(let curve):
//                    switch curve.order {
//                    case .cubic:
//                        path.curve(to: curve.end, controlPoint1: curve.controls[0], controlPoint2: curve.controls[1])
//                    default:
//                        assertionFailure("Unsupport bezier curve order.")
//                    }
//                case .path(let newPath):
//                    path.append(newPath.toBezierPath())
//                case .close:
//                    path.close()
//                }
//            }
//            return path
//        }
//    }
// #endif
