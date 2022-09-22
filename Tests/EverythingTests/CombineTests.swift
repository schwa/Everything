import Combine
@testable import Everything
import XCTest

class CombineTests: XCTestCase {
    func testExample() {
        XCTAssertEqual(Just(1).block(), 1)
        XCTAssertEqual(Just(1).block(), 1)

        XCTAssertEqual(Publishers.Sequence(sequence: [1, 2, 3]).block(), 3)
    }
}
