import Everything
import XCTest

class TaggedTests: XCTestCase {
    func test1() {
        enum FooTag {}
        typealias FooIdentifier = Tagged<FooTag, String>
        let id = FooIdentifier("x")
        let id2: FooIdentifier = "x"
        XCTAssertEqual(id, id2)
    }
}
