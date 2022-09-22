@testable import Everything
import XCTest

class ComparisonTests: XCTestCase {
    func testExample() {
        XCTAssertEqual(compare(1, 1), Comparison.equal)
        XCTAssertEqual(compare(1, 2), Comparison.lesser)
        XCTAssertEqual(compare(2, 1), Comparison.greater)
    }
}
