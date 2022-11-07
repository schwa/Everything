@testable import Everything
import XCTest

// func XCTAssertEqual<T: Equatable>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, @autoclosure _ expression3: () -> T, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
//    XCTAssertEqual(expression1, expression2, message, file: file, line: line)
//    XCTAssertEqual(expression2, expression3, message, file: file, line: line)
//    XCTAssertEqual(expression3, expression1, message, file: file, line: line)
// }

// func XCTAssertThrows(_ closure: () throws -> Void) {
//    do {
//        try closure()
//        XCTAssert(false)
//    }
//    catch {
//        return
//    }
// }

func bits(_ bits: Int) -> Int {
    bits * 8
}

func buildBinary(_ count: Int, closure: (UnsafeMutableBufferPointer<UInt8>) -> Void) -> [UInt8] {
    var data = [UInt8](repeating: 0, count: Int(ceil(Double(count) / 8)))
    data.withUnsafeMutableBufferPointer {
        (buffer: inout UnsafeMutableBufferPointer<UInt8>) in
        closure(buffer)
    }
    return data
}

struct BitString {
    var string: String

    init(count: Int) {
        string = String(repeating: "0", count: count)
    }

//    mutating func bitSet(_ start: Int, length: Int, newValue: UIntMax) throws {
//
//        let newValue = try binary(newValue, width: length, prefix: false)
//
//        let start = string.index(string.startIndex, offsetBy: start)
//        let end = <#T##String.CharacterView corresponding to `start`##String.CharacterView#>.index(start, offsetBy: length)
//        string.replaceRange(start..<end, with: newValue)
//    }
}
