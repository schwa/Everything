@testable import Everything
import XCTest

final class CollectionScannerTests: XCTestCase {
    func test() {
        var scanner = CollectionScanner(elements: "hello world")
        XCTAssertEqual(scanner.scan(count: 100), nil)
        XCTAssertEqual(scanner.atEnd, false)
        XCTAssertEqual(scanner.remainingCount, scanner.elements.count)
        XCTAssertEqual(scanner.remaining, "hello world")
        XCTAssertEqual(scanner.atEnd, false)
        XCTAssertEqual(scanner.scan(count: 0), "")
        XCTAssertEqual(scanner.scan(count: 5), "hello")
        XCTAssertEqual(scanner.atEnd, false)
        XCTAssertEqual(scanner.peek(), " ")
        XCTAssertEqual(scanner.scan(value: " "), true)
        XCTAssertEqual(scanner.atEnd, false)
        XCTAssertEqual(scanner.scan(value: Array("world!!!")), false)
        XCTAssertEqual(scanner.atEnd, false)
        XCTAssertEqual(scanner.scan(value: Array("WORLD")), false)
        XCTAssertEqual(scanner.atEnd, false)
        print(scanner.debugDescription)
        XCTAssertEqual(scanner.scan(value: Array("world")), true)
        XCTAssertEqual(scanner.atEnd, true)
        XCTAssertEqual(scanner.scan(count: 100), nil)
        XCTAssertEqual(scanner.scan(value: "X"), false)
        XCTAssertEqual(scanner.scan(value: ["X"]), false)
        XCTAssertEqual(scanner.remaining, "")
        XCTAssertEqual(scanner.remainingCount, 0)
        XCTAssertEqual(scanner.peek(), nil)
        XCTAssertEqual(scanner.peek(), nil)
    }

    func test2() {
        var scanner = CollectionScanner(elements: "hello world")
        XCTAssertEqual(scanner.current, scanner.elements.startIndex)
        XCTAssertEqual(scanner.scan(value: Array("XYZZY")), false)
        XCTAssertEqual(scanner.current, scanner.elements.startIndex)
        XCTAssertEqual(scanner.scan(value: Array("hello")), true)
        XCTAssertEqual(scanner.scan(value: " "), true)
        XCTAssertEqual(scanner.scan(value: Array("world")), true)
        XCTAssertEqual(scanner.atEnd, true)
    }

    func test3() {
        var scanner = CollectionScanner(elements: "a,b,c")
        XCTAssertEqual(scanner.scan(componentsSeparatedBy: ","), ["a", "b", "c"])
        XCTAssertEqual(scanner.atEnd, true)
        XCTAssertEqual(scanner.scan(componentsSeparatedBy: ","), [])
    }

    func test4() {
        var scanner = CollectionScanner(elements: "a_b-c")
        XCTAssertEqual(scanner.scan(until: { "_-".contains($0) }), "a")
        XCTAssertEqual(scanner.scan(anyOf: Array("_-")), "_")
        XCTAssertEqual(scanner.scan(anyOf: Array("1234")), nil)
        XCTAssertEqual(scanner.scan(until: { "_-".contains($0) }), "b")
        XCTAssertEqual(scanner.scan(anyOf: Array("_-")), "-")
        XCTAssertEqual(scanner.scan(until: { "_-".contains($0) }), "c")
        XCTAssertEqual(scanner.atEnd, true)
    }

    func test5() {
        var scanner = CollectionScanner(elements: "a,b,")
        XCTAssertEqual(scanner.scanUpTo(value: ","), "a")
        XCTAssertEqual(scanner.scan(value: ","), true)
        XCTAssertEqual(scanner.scanUpTo(value: ","), "b")
        XCTAssertEqual(scanner.scan(value: ","), true)
        XCTAssertEqual(scanner.scanUpTo(value: ","), nil)
        XCTAssertEqual(scanner.atEnd, true)
    }

    func test6() {
        var scanner = CollectionScanner(elements: "a+++b+++")
        XCTAssertEqual(scanner.scanUpTo(value: Array("+++")), "a")
        XCTAssertEqual(scanner.scan(value: Array("+++")), true)
        XCTAssertEqual(scanner.scanUpTo(value: Array("+++")), "b")
        XCTAssertEqual(scanner.scan(value: Array("+++")), true)
        XCTAssertEqual(scanner.scanUpTo(value: Array("+++")), nil)
        XCTAssertEqual(scanner.atEnd, true)
    }

    func test7() {
        var scanner = CollectionScanner(elements: "a+++b++")
        XCTAssertEqual(scanner.scanUpTo(value: Array("+++")), "a")
        XCTAssertEqual(scanner.scan(value: Array("+++")), true)
        XCTAssertEqual(scanner.scanUpTo(value: Array("+++")), nil)
        XCTAssertEqual(scanner.atEnd, false)
        XCTAssertEqual(scanner.scan(value: Array("b++")), true)
        XCTAssertEqual(scanner.atEnd, true)
    }
}
