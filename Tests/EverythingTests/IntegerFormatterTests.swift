@testable import Everything
import Foundation
import XCTest

class IntegerFormatterTests: XCTestCase {
    func test1() {
        XCTAssertEqual(IntegerStringFormatter(radix: 2).format(UInt8.zero), "0")
        XCTAssertEqual(IntegerStringFormatter(radix: 2).format(UInt8.max), "11111111")
        XCTAssertEqual(IntegerStringFormatter(radix: 2).format(UInt8(0b11)), "11")
        XCTAssertEqual(IntegerStringFormatter(radix: 2, width: .count(4)).format(UInt8(0b11)), "0011")
        XCTAssertEqual(IntegerStringFormatter(radix: 2, width: .count(2)).format(UInt8.max), "11")
    }
}
