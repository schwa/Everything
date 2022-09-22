@testable import Everything
import XCTest

class BitRangeTests: XCTestCase {
    func testScalarBitRange() {
        XCTAssertEqual(bitRange(value: UInt8(0b0001_1011), start: 0, count: 2, flipped: false), 0b11)
        XCTAssertEqual(bitRange(value: UInt8(0b0001_1011), start: 2, count: 2, flipped: false), 0b10)
        XCTAssertEqual(bitRange(value: UInt8(0b0001_1011), start: 4, count: 2, flipped: false), 0b01)
        XCTAssertEqual(bitRange(value: UInt8(0b0001_1011), start: 6, count: 2, flipped: false), 0b00)

        XCTAssertEqual(bitRange(value: UInt8(0b0001_1011), start: 0, count: 2, flipped: true), 0b00)
        XCTAssertEqual(bitRange(value: UInt8(0b0001_1011), start: 2, count: 2, flipped: true), 0b01)
        XCTAssertEqual(bitRange(value: UInt8(0b0001_1011), start: 4, count: 2, flipped: true), 0b10)
        XCTAssertEqual(bitRange(value: UInt8(0b0001_1011), start: 6, count: 2, flipped: true), 0b11)
    }

    func testScalarBitSet() {
        XCTAssertEqual(bitSet(value: UInt8(0b0001_1011), start: 0, count: 3, flipped: false, newValue: UInt8(0b100)), UInt8(0b0001_1100))
        XCTAssertEqual(bitSet(value: UInt8(0b0001_1011), start: 2, count: 1, flipped: false, newValue: UInt8(0b1)), UInt8(0b0001_1111))
        XCTAssertEqual(bitSet(value: UInt8(0b0001_1111), start: 0, count: 3, flipped: true, newValue: UInt8(0b111)), UInt8(0b1111_1111))
        XCTAssertEqual(bitSet(value: UInt8(0b0000_0000), range: 5 ..< 8, flipped: true, newValue: UInt8(5)), UInt8(5))
    }

    // TODO:
//    func testBufferRange1() {
//
//        let tests: [(Int,Int,UIntMax)] = [
    /// /            (0, 1, 0x1),
//            (0, 4, 0x1111),
//        ]
//
//        let count = 32
//
//        for test in tests {
//            let result = buildBinary(count) {
//                (buffer) in
//                bitSet(buffer, start: test.0, count: test.1, newValue: test.2)
//                print(test.0, test.1)
//            }
//
//            var bitString = BitString(count: count)
//            try! bitString.bitSet(test.0, count: test.1, newValue: test.2)
//
//            XCTAssertEqual(bitString.string, try! byteArrayToBinary(result))
//        }
//    }
}
