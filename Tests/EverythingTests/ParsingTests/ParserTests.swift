@testable import Everything
import XCTest

class ParserTests: XCTestCase {
    func testDelimitedList() {
        let identifier = identifierValue()
        let list = DelimitedList(subelement: identifier, min: 2, max: 2)
        let result = try! list.parse("hello, world") as! [Any]
        XCTAssertEqual(result[0] as? String, "hello")
        XCTAssertEqual(result[1] as? String, "world")
    }

    func testExample() {
        let wildcardSelector = Literal("*")
        let nameSelector = try! Pattern("^[a-zA-Z_]+")
        let indexedSelector = try! Pattern("^[0-9]+")

        let LBRACKET = Literal("[").makeStripped()
        let RBRACKET = Literal("]").makeStripped()
        let COMMA = Literal(",").makeStripped()

        let rootOperator = Literal("$").makeStripped()
        let dotOperator = Literal(".")

        let selector = (nameSelector | indexedSelector | wildcardSelector)

        let dotPathElement = (dotOperator + selector)

        let nameSelectorsList = (nameSelector + zeroOrMore(COMMA + nameSelector).setID("#1"))
        let bracketPathElement = (LBRACKET + (nameSelectorsList | selector) + RBRACKET)

        let pathElement = (dotPathElement | bracketPathElement)

        let path = (rootOperator + oneOrMore(pathElement).setID("#2"))

        let parser = (path + atEnd)

        let result = try! parser.parse("$[foo,bar]")
        print(result as Any)
    }
}
