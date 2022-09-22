@testable import Everything
import Foundation
import XCTest

class IdentifiableSetTests: XCTestCase {
    struct S: Identifiable, ExpressibleByStringLiteral {
        let id: String
        init(stringLiteral value: String) {
            id = value
        }
    }

    func test1() {
        var set = IdentifiableSet<S>()
        XCTAssert(set.isEmpty)
        XCTAssert(set.isEmpty)
        XCTAssert(!set.contains("A"))
        set.insert("A")
        XCTAssert(!set.isEmpty)
        XCTAssert(set.count == 1)
        XCTAssert(set.contains("A"))
        set.remove("A")
        XCTAssert(set.isEmpty)
        XCTAssert(set.isEmpty)
        XCTAssert(!set.contains("A"))
    }

    func test2() {
        let set = IdentifiableSet<S>(["A", "B"])
        XCTAssert(!set.isEmpty)
        XCTAssert(set.count == 2)
        XCTAssert(set.contains("A"))
        XCTAssert(set.contains("B"))
        XCTAssert(set.intersection(["A", "B"]).count == 2)
        XCTAssert(set.intersection(["C", "D"]).isEmpty)
        XCTAssert(set.intersection(["A", "C"]).count == 1)
    }
}
