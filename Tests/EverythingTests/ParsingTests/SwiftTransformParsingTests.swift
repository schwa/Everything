@testable import Everything
import XCTest

let COMMA = Literal(",")
let OPT_COMMA = zeroOrOne(COMMA).makeStripped()
let LPAREN = Literal("(").makeStripped()
let RPAREN = Literal(")").makeStripped()
let VALUE_LIST = oneOrMore((DoubleValue() + OPT_COMMA).makeStripped().makeFlattened())

// TODO: Should set manual min and max value instead of relying on 0..<infinite VALUE_LIST

let matrix = (Literal("matrix") + LPAREN + VALUE_LIST + RPAREN)
let translate = (Literal("translate") + LPAREN + VALUE_LIST + RPAREN)
let scale = (Literal("scale") + LPAREN + VALUE_LIST + RPAREN)
let rotate = (Literal("rotate") + LPAREN + VALUE_LIST + RPAREN)
let skewX = (Literal("skewX") + LPAREN + VALUE_LIST + RPAREN)
let skewY = (Literal("skewY") + LPAREN + VALUE_LIST + RPAREN)
let transform = (matrix | translate | scale | rotate | skewX | skewY).makeFlattened()
let transforms = oneOrMore((transform + OPT_COMMA).makeFlattened())

class MoreEverythingTests: XCTestCase {
    func testExample() {
        let result = try! transforms.parse("translate(0,0)")
        if let value = result as? [Any] {
            if let value = value[0] as? [Any] {
                let type = value[0] as? String
                XCTAssertEqual(type!, "translate")
                // TODO: now values
            }
        }
    }

    func testExample2() {
        let result = try! transforms.parse("translate(0)")
        if let value = result as? [Any] {
            if let value = value[0] as? [Any] {
                let type = value[0] as? String
                XCTAssertEqual(type!, "translate")
                // TODO: now values
            }
        }
    }
}
