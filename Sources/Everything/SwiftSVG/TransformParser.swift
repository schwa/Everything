// swiftlint:disable identifier_name

import CoreGraphics
import Foundation

func converter(value: Any) throws -> Any? {
    guard let value = value as? [Any], let type = value[0] as? String else {
        return nil
    }

    guard let parametersUntyped = (value[1] as? [Any]) else {
        return nil
    }

    let parameters: [CGFloat] = parametersUntyped.map { $0 as! CGFloat }

    switch type {
    case "matrix":
        let parameters = parameters + [CGFloat](repeating: 0.0, count: 6 - parameters.count)
        let a = parameters[0]
        let b = parameters[1]
        let c = parameters[2]
        let d = parameters[3]
        let e = parameters[4]
        let f = parameters[5]
        return MatrixTransform2D(a: a, b: b, c: c, d: d, tx: e, ty: f)
    case "translate":
        let parameters = parameters + [CGFloat](repeating: 0.0, count: 2 - parameters.count)
        let x = parameters[0]
        let y = parameters[1]
        return Translate(tx: x, ty: y)
    case "scale":
        let x = parameters[0]
        let y = parameters.count > 1 ? parameters[1] : x
        return Scale(sx: x, sy: y)
    case "rotate":
        let angle = parameters[0]
        return Rotate(angle: angle)
    default:
        return nil
    }
}

let COMMA = Literal(",")
let OPT_COMMA = zeroOrOne(COMMA).makeStripped()
let LPAREN = Literal("(").makeStripped()
let RPAREN = Literal(")").makeStripped()
let VALUE_LIST = oneOrMore((DoubleValue() + OPT_COMMA).makeStripped().makeFlattened())

// TODO: Should set manual min and max value instead of relying on 0..<infinite VALUE_LIST

let matrix = (Literal("matrix") + LPAREN + VALUE_LIST + RPAREN).makeConverted(converter)
let translate = (Literal("translate") + LPAREN + VALUE_LIST + RPAREN).makeConverted(converter)
let scale = (Literal("scale") + LPAREN + VALUE_LIST + RPAREN).makeConverted(converter)
let rotate = (Literal("rotate") + LPAREN + VALUE_LIST + RPAREN).makeConverted(converter)
let skewX = (Literal("skewX") + LPAREN + VALUE_LIST + RPAREN).makeConverted(converter)
let skewY = (Literal("skewY") + LPAREN + VALUE_LIST + RPAREN).makeConverted(converter)
let transform = (matrix | translate | scale | rotate | skewX | skewY).makeFlattened()
let transforms = oneOrMore((transform + OPT_COMMA).makeFlattened())

// rotate(<rotate-angle> [<cx> <cy>]), which specifies a rotation by <rotate-angle> degrees about a given point.
// If optional parameters <cx> and <cy> are not supplied, the rotate is about the origin of the current user coordinate system. The operation corresponds to the matrix [cos(a) sin(a) -sin(a) cos(a) 0 0].
// If optional parameters <cx> and <cy> are supplied, the rotate is about the point (cx, cy). The operation represents the equivalent of the following specification: translate(<cx>, <cy>) rotate(<rotate-angle>) translate(-<cx>, -<cy>).
//
// skewX(<skew-angle>), which specifies a skew transformation along the x-axis.
//
// skewY(<skew-angle>), which specifies a skew transformation along the y-axis.

// MARK: -

public enum SVGError: Swift.Error {
    case generic(String)
}

public func svgTransformAttributeStringToTransform(string: String) throws -> Transform2D? {
    guard let result = try transforms.parse(string) else {
        throw SVGError.generic("oops")
    }
    let r = result as! [SVGTransform]
    let compound = CompoundTransform(transforms: r)
    return compound
}
