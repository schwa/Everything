@testable import Everything
import XCTest

class CharacterSetTests: XCTestCase {
    func testExample() {
        let set = YACharacterSet.whitespaces

        XCTAssertTrue(set.contains(" "))
        XCTAssertTrue(set.contains("\n"))
        XCTAssertTrue(set.contains("\r"))
        XCTAssertTrue(set.contains("\t"))

        XCTAssertFalse(set.contains("x"))
        XCTAssertFalse(set.contains("\\"))
    }
}
