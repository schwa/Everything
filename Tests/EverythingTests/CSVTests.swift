@testable import Everything
import XCTest

final class CSVTests: XCTestCase {
    func testCSVFieldsAll() {
        let items: [(String, String, [String])] = [
            ("Test 1", "", []),
            ("Test 2", ",", ["", ""]),
            ("Test 3", "hello", ["hello"]),
            ("Test 4", "hello,world", ["hello", "world"]),
            ("Test 5", "hello,", ["hello", ""]),
            ("Test 6", ",hello", ["", "hello"]),
            ("Test 7", "\"hello\"", ["hello"]),
            ("Test 8", "\"hello\",world", ["hello", "world"]),
            ("Test 9", "hello,\"world\"", ["hello", "world"]),
            ("Test 10", "\"\"\"\"", ["\""]),
            ("Test 11", "\"Hello\"\"\"", ["Hello\""]),
            ("Test 12", "\"\"\"Hello\"", ["\"Hello"]),
        ]
        for (message, input, expectedOutput) in items {
            let output = CollectionScanner(elements: input).scan { $0.scanCSVFields() }
            XCTAssertEqual(output, expectedOutput, message)
        }
    }

    func testEmptyCSV() {
        let reader = CSVDictReader(data: "".data(using: .utf8)!)
        let rows = reader.makeIterator().collect()
        XCTAssertEqual(rows.count, 0)
    }

    func testCSV() {
        let content = #"""
        Fruit,Color
        "Apple",Green
        Banana,"Yellow"
        "Orange","Orange"
        """#

        let reader = CSVDictReader(data: content.data(using: .utf8)!, lineEndings: .LF)
        let rows = reader.makeIterator().collect()
        XCTAssertEqual(rows.count, 3)
        XCTAssertEqual(rows[0], ["Fruit": "Apple", "Color": "Green"])
        XCTAssertEqual(rows[1], ["Fruit": "Banana", "Color": "Yellow"])
        XCTAssertEqual(rows[2], ["Fruit": "Orange", "Color": "Orange"])
    }
}
