@testable import Everything
import XCTest

func XCTAssertNoThrow(_ block: () throws -> Void) {
    do {
        try block()
    }
    catch {
        XCTAssertTrue(false)
    }
}

func XCTAssertThrows(_ block: () throws -> Void) {
    do {
        try block()
    }
    catch {
        return
    }
    XCTAssertTrue(false)
}

@available(*, deprecated, message: "Use Scanner or CollectionScanner instead?")
class ScannerTests: XCTestCase {
    func testScanSimpleString() {
        let scanner = YAScanner(string: "Hello world")
        XCTAssert(scanner.scan(string: "Hello") == true)
        XCTAssert(scanner.scan(string: "world") == true)
        XCTAssert(scanner.atEnd == true)
    }

    func testScanTooMuchSimpleString() {
        let scanner = YAScanner(string: "Hello")
        XCTAssert(scanner.scan(string: "Hello world") == false)
        XCTAssert(scanner.atEnd == false)
    }

    func testScanCharSet() {
        let scanner = YAScanner(string: "01234")
        XCTAssert(scanner.scan(charactersFromSet: YACharacterSet.decimalDigits) == "01234")
        XCTAssert(scanner.atEnd == true)
    }

    func testBadScanCharSet() {
        let scanner = YAScanner(string: "abcde")
        XCTAssert(scanner.scan(charactersFromSet: YACharacterSet.decimalDigits) == nil)
        XCTAssert(scanner.atEnd == false)
    }

    func testScanSingleCharSet() {
        let scanner = YAScanner(string: "0")
        XCTAssert(scanner.scan(characterFromSet: YACharacterSet.decimalDigits) == Character("0"))
        XCTAssert(scanner.atEnd == true)
    }

    func testScanNoSingleCharSet() {
        let scanner = YAScanner(string: "A")
        XCTAssert(scanner.scan(characterFromSet: YACharacterSet.decimalDigits) == nil)
        XCTAssert(scanner.atEnd == false)
    }

    func testScanSingleChar() {
        let scanner = YAScanner(string: "0A")
        XCTAssert(scanner.scan(character: Character("0")) == true)
        XCTAssert(scanner.scan(character: Character("X")) == false)
    }

    func testScanSimpleStringNoSkip() {
        let scanner = YAScanner(string: "Hello world")
        scanner.skippedCharacters = nil
        XCTAssert(scanner.scan(string: "Hello") == true)
        XCTAssert(scanner.scan(string: " ") == true)
        XCTAssert(scanner.scan(string: "world") == true)
        XCTAssert(scanner.atEnd == true)
    }

    func testScanSuppressSkip() {
        let scanner = YAScanner(string: "Hello world")
        scanner.suppressSkip {
            XCTAssert(scanner.scan(string: "Hello") == true)
            XCTAssert(scanner.scan(string: " ") == true)
            XCTAssert(scanner.scan(string: "world") == true)
            XCTAssert(scanner.atEnd == true)
        }
    }

    func testScanBadBack() {
        let scanner = YAScanner(string: "")
        XCTAssertThrows {
            try scanner.back()
        }
    }

    func testScanRegularExpression() {
        let scanner = YAScanner(string: "Hello world")
        let result = try! scanner.scan(regularExpression: "H[^\\s]+")
        XCTAssert(result == "Hello")
        XCTAssert(scanner.remaining == " world")

        let result2 = try! scanner.scan(regularExpression: "w[^\\s]+")
        XCTAssert(result2 == "world")
    }

    func testScanNotRegularExpression() {
        let scanner = YAScanner(string: "Hello world")
        let result = try! scanner.scan(regularExpression: "[0-9]+")
        XCTAssert(result == nil)
    }

    func testScanRegularExpression2() {
        let scanner = YAScanner(string: "name")
        XCTAssertEqual(try! scanner.scan(regularExpression: "[A-Za-z_]+"), "name")
    }

    func testEmpty() {
        let scanner = YAScanner(string: "")
        _ = scanner.scan(string: "X")
    }

    func testScanFiddlyJSONPath() {
        let scanner = YAScanner(string: "$.store.book[0].title")

        XCTAssert(scanner.scan(string: "$") == true)
        XCTAssert(scanner.scan(string: ".") == true)
        XCTAssertEqual(try! scanner.scan(regularExpression: "[\\w_]+"), "store")
        XCTAssert(scanner.scan(string: ".") == true)
        XCTAssertEqual(try! scanner.scan(regularExpression: "[\\w_]+"), "book")
        XCTAssert(scanner.scan(string: "[") == true)
        XCTAssertEqual(try! scanner.scan(regularExpression: "[\\d_]+"), "0")
        XCTAssert(scanner.scan(string: "]") == true)
        XCTAssert(scanner.scan(string: ".") == true)
        XCTAssertEqual(try! scanner.scan(regularExpression: "[\\w_]+"), "title")
    }
}
