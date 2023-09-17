@testable import Everything
import XCTest

@available(*, deprecated, message: "Deprecated")
class RegularExpressionTests: XCTestCase {
    func testExample1() {
        let regex = try! RegularExpression("[a-z]+")
        let match = regex.search("00000 world")
        XCTAssertEqual(match?.strings[0], "world")
    }

    func testExample2() {
        let regex = try! RegularExpression("[a-z]+")
        let match = regex.match("00000 world")
        XCTAssertNil(match)
    }
}
