@testable import Everything
import XCTest

class Tests: XCTestCase {
    func testGetters() {
        XCTAssertEqual(UInt32(0xDEAD_BEEF).bits[0 ... 7], 0xEF)
        XCTAssertEqual(UInt32(0xDEAD_BEEF).bits[0 ..< 8], 0xEF)
        XCTAssertEqual(UInt32(0xDEAD_BEEF).bits[...7], 0xEF)
        XCTAssertEqual(UInt32(0xDEAD_BEEF).bits[..<8], 0xEF)

        XCTAssertEqual(UInt32(0xDEAD_BEEF).bits[24 ... 31], 0xDE)
        XCTAssertEqual(UInt32(0xDEAD_BEEF).bits[24 ..< 32], 0xDE)
        XCTAssertEqual(UInt32(0xDEAD_BEEF).bits[24...], 0xDE)

        XCTAssertEqual(UInt32(0xDEAD_BEEF).bits[8 ... 23], 0xADBE)
        XCTAssertEqual(UInt32(0xDEAD_BEEF).bits[8 ..< 24], 0xADBE)
    }

    func testSetters() {
        var value: UInt32 = 0xDEAD_BEEF

        value.bits[0 ... 7] = 0x12
        XCTAssertEqual(value, 0xDEAD_BE12)

        value = 0xDEAD_BEEF
        value.bits[0 ..< 8] = 0x12
        XCTAssertEqual(value, 0xDEAD_BE12)

        value = 0xDEAD_BEEF
        value.bits[...7] = 0x12
        XCTAssertEqual(value, 0xDEAD_BE12)

        value = 0xDEAD_BEEF
        value.bits[..<8] = 0x12
        XCTAssertEqual(value, 0xDEAD_BE12)

        value = 0xDEAD_BEEF
        value.bits[24 ... 31] = 0x12
        XCTAssertEqual(value, 0x12AD_BEEF)

        value = 0xDEAD_BEEF
        value.bits[24 ..< 32] = 0x12
        XCTAssertEqual(value, 0x12AD_BEEF)

        value = 0xDEAD_BEEF
        value.bits[24...] = 0x12
        XCTAssertEqual(value, 0x12AD_BEEF)

        value = 0xDEAD_BEEF
        value.bits[8 ... 23] = 0x1234
        XCTAssertEqual(value, 0xDE12_34EF)

        value = 0xDEAD_BEEF
        value.bits[8 ..< 24] = 0x1234
        XCTAssertEqual(value, 0xDE12_34EF)
    }
}

