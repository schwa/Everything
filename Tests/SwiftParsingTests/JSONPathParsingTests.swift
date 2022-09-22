import XCTest

import SwiftParsing

// class JSONPathParsingTests: XCTestCase {
//    var json: AnyObject!
//
//    override func setUp() {
//        let bundle = Bundle(for: type(of: self))
//        let url = bundle.url(forResource: "sample", withExtension: "json")!
//        let data = try! Data(contentsOf: url)
//        json = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as AnyObject!
//    }
//
//    // MARK: test 1
//    // the authors of all books in the store
//    func test1() {
//        let path = try! JSONPath("$.store.book[*].author", compile: true)
//        let result: [String] = try! path.evaluate(json!)
//        let expected = ["Nigel Rees", "Evelyn Waugh", "Herman Melville", "J. R. R. Tolkien"]
//        zip(result, expected).forEach() {
//            XCTAssertEqual($0, $1)
//        }
//    }
//
//    // MARK: test 1 alt 1
//    // the authors of all books in the store
//    func test1_alt1() {
//        let path = try! JSONPath("$[store][book][*][author]", compile: true)
//        let result: [String] = try! path.evaluate(json!)
//        let expected = ["Nigel Rees", "Evelyn Waugh", "Herman Melville", "J. R. R. Tolkien"]
//        zip(result, expected).forEach() {
//            XCTAssertEqual($0, $1)
//        }
//    }
//
//    // MARK: test 1 alt 2
//    // the authors of all books in the store
//    func test1_alt2() {
//        let path = try! JSONPath("$.store.book.*.author", compile: true)
//        let result: [String] = try! path.evaluate(json!)
//        let expected = ["Nigel Rees", "Evelyn Waugh", "Herman Melville", "J. R. R. Tolkien"]
//        zip(result, expected).forEach() {
//            XCTAssertEqual($0, $1)
//        }
//    }
//
//    // MARK: test2
//    // $..author
//
//    // MARK: test3
//    // ?
//
//    // MARK: test4
//    // $.store..price
//
//    // MARK: test5
//    // $..book[2]
//
//    // MARK: test6
//    //$..book[(@.length-1)]
//    //$..book[-1: ]
//
//    // MARK: Test 7
//    //$..book[0,1]
//    //$..book[:2]
//
//    // MARK: Test 8
//    //$..book[?(@.isbn)]
//
//    // MARK: Test 9
//    //$..book[?(@.price<10)]
//
//
//    // MARK: Test 10
//    //$..*
//
//
//    // MARK: Custom Tests
//
//
//    func test_custom_1() {
//        let path = try! JSONPath("$.store.book.0.title", compile: true)
//        let result = try! path.evaluate(json!)
//        XCTAssertEqual(result as? String, "Sayings of the Century")
//    }
//
//    func test_custom_2() {
//        let path = try! JSONPath("$.store.book.0.price", compile: true)
//        let result = try! path.evaluate(json!)
//        XCTAssertEqual(result as? Double, 8.95)
//    }
//
//    func test_custom_3() {
//        let path = try! JSONPath("$.store.book.0[title,author]", compile: true)
//        let result = try! path.evaluate(json!) as! [AnyObject]
//        XCTAssertEqual(result[0] as? String, "Sayings of the Century")
//        XCTAssertEqual(result[1] as? String, "Nigel Rees")
//    }
//
// }
