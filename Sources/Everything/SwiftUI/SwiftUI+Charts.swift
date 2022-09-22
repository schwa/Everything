import SwiftUI

public struct BarChart: Shape {
    public let values: [Double]

    var range: ClosedRange<Double> {
        let minValue = values.reduce(Double.infinity, min)
        let maxValue = values.reduce(-Double.infinity, max)
        return minValue ... maxValue
    }

    public func path(in rect: CGRect) -> Path {
        // let xdelta = rect.size.width / CGFloat(values.count - 1)
        let xdelta: CGFloat = 6
        let minValue = values.reduce(Double.infinity, min)
        let maxValue = values.reduce(-Double.infinity, max)
        let range = minValue ... maxValue
        let rects = values.map {
            range.isZero ? 0 : range.normalize($0)
        }
        .enumerated()
        .map { index, value -> CGRect in
            let y = CGFloat(value) * rect.size.height
            return CGRect(x: xdelta * CGFloat(index), y: 0, width: 4, height: y)
        }
        return Path { path in
            rects.forEach { rect in
                path.addRect(rect)
            }
        }
    }
}

public struct LineChart: Shape {
    public let values: [Double]
    public let open: Bool

//    var animatableData: [Double] {
//        get {
//            return values
//        }
//        set {
//            self.values = newValue
//        }
//    }

    var range: ClosedRange<Double> {
        let minValue = values.reduce(Double.infinity, min)
        let maxValue = values.reduce(-Double.infinity, max)
        return minValue ... maxValue
    }

    public init(values: [Double], open: Bool = true) {
        self.values = values
        self.open = open
    }

    public func path(in rect: CGRect) -> Path {
        let xdelta = rect.size.width / CGFloat(values.count - 1)
        let minValue = values.reduce(Double.infinity, min)
        let maxValue = values.reduce(-Double.infinity, max)
        let range = minValue ... maxValue
        let points = values.map {
            range.isZero ? 0 : range.normalize($0)
        }
        .enumerated()
        .map { index, value -> CGPoint in
            let y = CGFloat(1 - value) * rect.size.height
            return CGPoint(x: xdelta * CGFloat(index), y: y)
        }

        if open {
            return Path { path in
                path.move(to: points.first!)
                path.addLines(points)
            }
        }
        else {
            return Path { path in
                path.move(to: points.first!)
                path.addLine(to: points.first!)
                path.addLines(points)
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.closeSubpath()
            }
        }
    }
}
