@testable import Everything
import Foundation
import XCTest

class FormatStyleTests: XCTestCase {
    func testIntegerFormatStyle() {
        XCTAssertEqual(RadixedIntegerFormatStyle(radix: 2).format(UInt8.zero), "0")
        XCTAssertEqual(RadixedIntegerFormatStyle(radix: 2).format(UInt8.max), "11111111")
        XCTAssertEqual(RadixedIntegerFormatStyle(radix: 2).format(UInt8(0b11)), "11")
        XCTAssertEqual(RadixedIntegerFormatStyle(radix: 2, width: .count(4)).format(UInt8(0b11)), "0011")
        XCTAssertEqual(RadixedIntegerFormatStyle(radix: 2, width: .count(2)).format(UInt8.max), "11")

        XCTAssertEqual("\(255, format: .hex)", "0xFF")
        XCTAssertEqual(Int(255).formatted(.hex), "0xFF")
        XCTAssertEqual(Int(65535).formatted(.hex.group(2)), "0xFF_FF")
    }

    func testOthers() {
        XCTAssertEqual("\(100, format: .described)", "100")
        XCTAssertEqual("\("100", format: .described)", "100")
    }

    func testHexdump() {
        var s = ""
        hexdump([1, 2, 3, 4], stream: &s)
        XCTAssertEqual(s, "0000000000000000  0x01 0x02 0x03 0x04                              ????\n")

        print("\(Data([0xDE, 0xED, 0xBE, 0xEF]), format: .hexdump)")
    }
}
