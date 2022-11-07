import Foundation
import QuartzCore

public protocol SVGTransform {
    var is2D: Bool { get } // TODO: Rename to "can be represented in 2D"
    var isIdentity: Bool { get }
}

public protocol Transform2D: SVGTransform {
    func toCGAffineTransform() -> CGAffineTransform
}

public extension Transform2D {
    var is2D: Bool {
        true
    }
}

public protocol Transform3D: SVGTransform {
    func asCATransform3D() -> CATransform3D
}

// MARK: -

public struct IdentityTransform: SVGTransform {
    public var isIdentity: Bool {
        true
    }
}

extension IdentityTransform: Transform2D {
    public func toCGAffineTransform() -> CGAffineTransform {
        CGAffineTransform.identity
    }
}

// MARK: -

public struct CompoundTransform: SVGTransform {
    public let transforms: [SVGTransform]

    public init(transforms: [SVGTransform]) {
        // TODO: Check that all transforms are also Transform2D? Or use another init?

        // TODO: Strip out identity transforms
        self.transforms = transforms.filter {
            $0.isIdentity == false
        }
    }

    public var isIdentity: Bool {
        if transforms.isEmpty {
            return true
        }
        else {
            // TODO: LIE
            return false
        }
    }
}

extension CompoundTransform: Transform2D {
    public func toCGAffineTransform() -> CGAffineTransform {
        // Convert all transforms to 2D transforms. We will explode if not all transforms are 2D capable
        let affineTransforms: [CGAffineTransform] = transforms.map {
            ($0 as! Transform2D).toCGAffineTransform()
        }

        let transform: CGAffineTransform = affineTransforms[0]
        let result: CGAffineTransform = affineTransforms[1 ..< affineTransforms.count].reduce(transform) { (lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform in
            lhs.concatenating(rhs)
        }
        return result
    }
}

public extension SVGTransform {
    static func + (lhs: SVGTransform, rhs: SVGTransform) -> CompoundTransform {
        CompoundTransform(transforms: [lhs, rhs])
    }

    static func + (lhs: SVGTransform, rhs: CompoundTransform) -> CompoundTransform {
        CompoundTransform(transforms: [lhs] + rhs.transforms)
    }
}

public extension CompoundTransform {
    static func + (lhs: CompoundTransform, rhs: SVGTransform) -> CompoundTransform {
        CompoundTransform(transforms: lhs.transforms + [rhs])
    }

    static func + (lhs: CompoundTransform, rhs: CompoundTransform) -> CompoundTransform {
        CompoundTransform(transforms: lhs.transforms + rhs.transforms)
    }
}

extension CompoundTransform: CustomStringConvertible {
    public var description: String {
        let transformStrings: [String] = transforms.map { String(describing: $0) }
        return "CompoundTransform(\(transformStrings))"
    }
}

// MARK: -

public struct MatrixTransform2D: SVGTransform {
    public let a: CGFloat
    public let b: CGFloat
    public let c: CGFloat
    public let d: CGFloat
    public let tx: CGFloat
    public let ty: CGFloat

    public var isIdentity: Bool {
        // TODO: LIE
        false
    }
}

extension MatrixTransform2D: Transform2D {
    public func toCGAffineTransform() -> CGAffineTransform {
        CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }
}

extension MatrixTransform2D: CustomStringConvertible {
    public var description: String {
        "Matrix(\(a), \(b), \(c) \(d), \(tx), \(ty))"
    }
}

// MARK: Translate

public struct Translate: SVGTransform {
    public let tx: CGFloat
    public let ty: CGFloat
    public let tz: CGFloat

    public init(tx: CGFloat, ty: CGFloat, tz: CGFloat = 0.0) {
        self.tx = tx
        self.ty = ty
        self.tz = tz
    }

    public var isIdentity: Bool {
        // TODO: LIE
        false
    }
}

extension Translate: Transform2D {
    public var is2D: Bool {
        tz == 0.0
    }

    public func toCGAffineTransform() -> CGAffineTransform {
        if tz != 0.0 {
            unimplemented()
        }
        return CGAffineTransform(translationX: tx, y: ty)
    }
}

extension Translate: Transform3D {
    public func asCATransform3D() -> CATransform3D {
        CATransform3DMakeTranslation(tx, ty, tz)
    }
}

extension Translate: CustomStringConvertible {
    public var description: String {
        "Translate(\(tx), \(ty), \(tz))"
    }
}

// MARK: Scale

public struct Scale: SVGTransform {
    public let sx: CGFloat
    public let sy: CGFloat
    public let sz: CGFloat

    public init(sx: CGFloat, sy: CGFloat, sz: CGFloat = 1) {
        self.sx = sx
        self.sy = sy
        self.sz = sz
    }

    public init(scale: CGFloat) {
        sx = scale
        sy = scale
        sz = scale
    }

    public var isIdentity: Bool {
        // TODO: LIE
        false
    }
}

extension Scale: Transform2D {
    public func toCGAffineTransform() -> CGAffineTransform {
        precondition(sz == 1.0)
        return CGAffineTransform(scaleX: sx, y: sy)
    }
}

extension Scale: Transform3D {
    public func asCATransform3D() -> CATransform3D {
        CATransform3DMakeScale(sx, sy, sz)
    }
}

extension Scale: CustomStringConvertible {
    public var description: String {
        "Scale(\(sx), \(sy), \(sz))"
    }
}

// MARK: -

public struct Rotate: SVGTransform {
    public let angle: CGFloat
    // AXIS, TRANSLATION

    public var isIdentity: Bool {
        // TODO: LIE
        false
    }
}

extension Rotate: Transform2D {
    public func toCGAffineTransform() -> CGAffineTransform {
        CGAffineTransform(rotationAngle: angle)
    }
}

extension Rotate: CustomStringConvertible {
    public var description: String {
        "Rotate(\(angle))"
    }
}

// MARK: -

public struct Skew: SVGTransform {
    public let angle: CGFloat
    // AXIS

    public var isIdentity: Bool {
        // TODO: LIE
        false
    }
}

extension Skew: Transform2D {
    // swiftlint:disable:next unavailable_function
    public func toCGAffineTransform() -> CGAffineTransform {
        fatalError("Cannot skew")
    }
}

extension Skew: CustomStringConvertible {
    public var description: String {
        "Skew(\(angle))"
    }
}
