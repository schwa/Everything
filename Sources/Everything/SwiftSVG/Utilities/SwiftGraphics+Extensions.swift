import CoreGraphics

public extension CGPath {
    static func + (lhs: CGPath, rhs: CGPath) -> CGPath {
        let path = lhs.mutableCopy()!
        path.addPath(rhs)
        return path
    }
}

// public extension CGColor {
//    var components: [CGFloat] {
//        let count = self.numberOfComponents
//        let componentsPointer = self.components
//        let components = UnsafeBufferPointer <CGFloat> (start: componentsPointer, count: count)
//        return Array(components)
//    }
//
// }

// extension CGColor: CustomReflectable {
//    public func customMirror() -> Mirror {
//        return Mirror(self, children: [
//            "alpha": alpha,
//            "colorSpace": colorSpaceName,
//            "components": components,
//        ])
//    }
// }

// extension CGColor: Equatable {
// }
//
// public func ==(lhs: CGColor, rhs: CGColor) -> Bool {
//
//    if lhs.alpha != rhs.alpha {
//        return false
//    }
//    if lhs.colorSpaceName != rhs.colorSpaceName {
//        return false
//    }
//    if lhs.components != rhs.components {
//        return false
//    }
//
//    return true
// }

// extension Style: Equatable {
// }
//
// public func ==(lhs: Style, rhs: Style) -> Bool {
//    if lhs.fillColor != rhs.fillColor {
//        return false
//    }
//    if lhs.strokeColor != rhs.strokeColor {
//        return false
//    }
//    if lhs.lineWidth != rhs.lineWidth {
//        return false
//    }
//    if lhs.lineCap != rhs.lineCap {
//        return false
//    }
//    if lhs.miterLimit != rhs.miterLimit {
//        return false
//    }
//    if lhs.lineDash ?? [] != rhs.lineDash ?? [] {
//        return false
//    }
//    if lhs.lineDashPhase != rhs.lineDashPhase {
//        return false
//    }
//    if lhs.flatness != rhs.flatness {
//        return false
//    }
//    if lhs.alpha != rhs.alpha {
//        return false
//    }
//    if lhs.blendMode != rhs.blendMode {
//        return false
//    }
//    return true
// }

// extension SwiftGraphics.Style {
//
//    init() {
//        self.init(elements: [])
//    }
//
//    var isEmpty: Bool {
//        get {
//            return toStyleElements().count == 0
//        }
//    }
//
//    func toStyleElements() -> [StyleElement] {
//
//        var elements: [StyleElement] = []
//
//        if let fillColor {
//            elements.append(.fillColor(fillColor))
//        }
//
//        if let strokeColor {
//            elements.append(.fillColor(strokeColor))
//        }
//
//        if let lineWidth {
//            elements.append(.lineWidth(lineWidth))
//        }
//
//        if let lineCap {
//            elements.append(.lineCap(lineCap))
//        }
//
//        if let lineJoin {
//            elements.append(.lineJoin(lineJoin))
//        }
//
//        if let miterLimit {
//            elements.append(.miterLimit(miterLimit))
//        }
//
//        if let lineDash {
//            elements.append(.lineDash(lineDash))
//        }
//
//        if let lineDashPhase {
//            elements.append(.lineDashPhase(lineDashPhase))
//        }
//
//        if let flatness {
//            elements.append(.flatness(flatness))
//        }
//
//        if let alpha {
//            elements.append(.alpha(alpha))
//        }
//
//        if let blendMode {
//            elements.append(.blendMode(blendMode))
//        }
//
//        return elements
//    }
// }
//
//
// func + (lhs: SwiftGraphics.Style, rhs: SwiftGraphics.Style) -> SwiftGraphics.Style {
//    var accumulator = lhs
//    accumulator.add(rhs.toStyleElements())
//    return accumulator
// }
//
