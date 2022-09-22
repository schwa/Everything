@testable import Everything
import XCTest

class VersionTests: XCTestCase {
    func testBasic() {
        let version = Version(major: 1, minor: 2, patch: 3)
        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 2)
        XCTAssertEqual(version.patch, 3)
        XCTAssertEqual(String(describing: version), "1.2.3")

        let version2 = try? Version("1.2.3")
        XCTAssertNotNil(version2)

        XCTAssertEqual(version, version2!)

        let version3 = Version(version.majorMinorPatch)
        XCTAssertEqual(version, version3)
    }

    func testLabels() {
        let version = try? Version("1.2.3-hello")
        XCTAssertEqual(version!.labels[0], "hello")
        let version2 = try? Version("1.2.3-hello.world")
        XCTAssertEqual(version2!.labels[0], "hello")
        XCTAssertEqual(version2!.labels[1], "world")
    }

    func testString() {
        let versions = [
            (try! Version("1"), Version(major: 1, minor: 0, patch: 0)),
            (try! Version("1.2"), Version(major: 1, minor: 2, patch: 0)),
            (try! Version("1.2.3"), Version(major: 1, minor: 2, patch: 3)),
            (try! Version("1.2.3-hello"), Version(major: 1, minor: 2, patch: 3, labels: ["hello"])),
            (try! Version("1.2.3-hello.world"), Version(major: 1, minor: 2, patch: 3, labels: ["hello", "world"])),
        ]
        for (lhs, rhs) in versions {
            XCTAssertEqual(lhs, rhs)
        }
    }

    func testComparisons() {
        XCTAssertGreaterThan(try! Version("2.0"), try! Version("1.0"))
        XCTAssertLessThan(try! Version("1.0"), try! Version("2.0"))
        XCTAssertGreaterThan(try! Version("2.0"), try! Version("1.1"))
        XCTAssertLessThan(try! Version("1.0"), try! Version("1.1"))
        XCTAssertLessThan(try! Version("1.0.2"), try! Version("1.0.3"))
    }

    func testLabelComparisons() {
        XCTAssertEqual(try! Version("1.0-a"), try! Version("1.0-a"))
        XCTAssertEqual(try! Version("1.0-10"), try! Version("1.0-10"))
        XCTAssertLessThan(try! Version("1.0-1"), try! Version("1.0-10"))
        XCTAssertLessThan(try! Version("1.0-10"), try! Version("1.0-100"))
        XCTAssertLessThan(try! Version("1.0-13"), try! Version("1.0-100"))

        XCTAssertLessThan(try! Version("1.0"), try! Version("1.0-1"))
    }

    func testLabelDegenerateCases() {
        XCTAssertNil(try? Version(""))
        XCTAssertNil(try? Version("weird"))
    }
}
