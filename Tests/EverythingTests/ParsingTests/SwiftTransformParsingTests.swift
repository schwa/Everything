@testable import Everything
import XCTest

@available(*, deprecated, message: "Deprecated")
class MoreEverythingTests: XCTestCase {
    static let COMMA = Literal(",")
    static let OPT_COMMA = zeroOrOne(COMMA).makeStripped()
    static let LPAREN = Literal("(").makeStripped()
    static let RPAREN = Literal(")").makeStripped()
    static let VALUE_LIST = oneOrMore((DoubleValue() + OPT_COMMA).makeStripped().makeFlattened())

    // TODO: Should set manual min and max value instead of relying on 0..<infinite VALUE_LIST

    static let matrix = (Literal("matrix") + LPAREN + VALUE_LIST + RPAREN)
    static let translate = (Literal("translate") + LPAREN + VALUE_LIST + RPAREN)
    static let scale = (Literal("scale") + LPAREN + VALUE_LIST + RPAREN)
    static let rotate = (Literal("rotate") + LPAREN + VALUE_LIST + RPAREN)
    static let skewX = (Literal("skewX") + LPAREN + VALUE_LIST + RPAREN)
    static let skewY = (Literal("skewY") + LPAREN + VALUE_LIST + RPAREN)

    static let transform = (matrix | translate | scale | rotate | skewX | skewY).makeFlattened()

    let transforms = oneOrMore((transform + OPT_COMMA).makeFlattened())


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
