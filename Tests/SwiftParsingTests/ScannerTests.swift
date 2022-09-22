import XCTest

import SwiftParsing

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

class ScannerTests: XCTestCase {
    func testScanSimpleString() {
        let scanner = SwiftParsing.Scanner(string: "Hello world")
        XCTAssert(scanner.scan(string: "Hello") == true)
        XCTAssert(scanner.scan(string: "world") == true)
        XCTAssert(scanner.atEnd == true)
    }

    func testScanTooMuchSimpleString() {
        let scanner = SwiftParsing.Scanner(string: "Hello")
        XCTAssert(scanner.scan(string: "Hello world") == false)
        XCTAssert(scanner.atEnd == false)
    }

    func testScanCharSet() {
        let scanner = SwiftParsing.Scanner(string: "01234")
        XCTAssert(scanner.scan(charactersFromSet: SimpleCharacterSet.decimalDigits) == "01234")
        XCTAssert(scanner.atEnd == true)
    }

    func testBadScanCharSet() {
        let scanner = SwiftParsing.Scanner(string: "abcde")
        XCTAssert(scanner.scan(charactersFromSet: SimpleCharacterSet.decimalDigits) == nil)
        XCTAssert(scanner.atEnd == false)
    }

    func testScanSingleCharSet() {
        let scanner = SwiftParsing.Scanner(string: "0")
        XCTAssert(scanner.scan(characterFromSet: SimpleCharacterSet.decimalDigits) == Character("0"))
        XCTAssert(scanner.atEnd == true)
    }

    func testScanNoSingleCharSet() {
        let scanner = SwiftParsing.Scanner(string: "A")
        XCTAssert(scanner.scan(characterFromSet: SimpleCharacterSet.decimalDigits) == nil)
        XCTAssert(scanner.atEnd == false)
    }

    func testScanSingleChar() {
        let scanner = SwiftParsing.Scanner(string: "0A")
        XCTAssert(scanner.scan(character: Character("0")) == true)
        XCTAssert(scanner.scan(character: Character("X")) == false)
    }

    func testScanSimpleStringNoSkip() {
        let scanner = SwiftParsing.Scanner(string: "Hello world")
        scanner.skippedCharacters = nil
        XCTAssert(scanner.scan(string: "Hello") == true)
        XCTAssert(scanner.scan(string: " ") == true)
        XCTAssert(scanner.scan(string: "world") == true)
        XCTAssert(scanner.atEnd == true)
    }

    func testScanSuppressSkip() {
        let scanner = SwiftParsing.Scanner(string: "Hello world")
        scanner.suppressSkip() {
            XCTAssert(scanner.scan(string: "Hello") == true)
            XCTAssert(scanner.scan(string: " ") == true)
            XCTAssert(scanner.scan(string: "world") == true)
            XCTAssert(scanner.atEnd == true)
        }
    }

    func testScanBadBack() {
        let scanner = SwiftParsing.Scanner(string: "")
        XCTAssertThrows {
            try scanner.back()
        }
    }

    func testScanRegularExpression() {
        let scanner = SwiftParsing.Scanner(string: "Hello world")
        let result = try! scanner.scan(regularExpression: "H[^\\s]+")
        XCTAssert(result == "Hello")
        XCTAssert(scanner.remaining == " world")

        let result2 = try! scanner.scan(regularExpression: "w[^\\s]+")
        XCTAssert(result2 == "world")
    }

    func testScanNotRegularExpression() {
        let scanner = SwiftParsing.Scanner(string: "Hello world")
        let result = try! scanner.scan(regularExpression: "[0-9]+")
        XCTAssert(result == nil)
    }

    func testScanRegularExpression2() {
        let scanner = SwiftParsing.Scanner(string: "name")
        XCTAssertEqual(try! scanner.scan(regularExpression: "[A-Za-z_]+"), "name")
    }

    func testEmpty() {
        let scanner = SwiftParsing.Scanner(string: "")
        _ = scanner.scan(string: "X")
    }

    func testScanFiddlyJSONPath() {
        let scanner = SwiftParsing.Scanner(string: "$.store.book[0].title")

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
