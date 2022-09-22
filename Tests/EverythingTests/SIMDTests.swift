////
////  File.swift
////
////
////  Created by Jonathan Wight on 12/9/19.
////
//
//@testable import Everything
//import Foundation
//import simd
//import XCTest
//
//class SIMDTests: XCTestCase {
//    func testVectors() {
//        XCTAssertEqual(SIMD2<Float>.zero, [0, 0])
//        XCTAssertEqual(SIMD2<Float>.unit, [1, 1])
//        XCTAssertEqual(SIMD2<Float>(1, 0).length, 1)
//        XCTAssertEqual(SIMD2<Float>(1, 1).length, 1.4142135, accuracy: 0.00001)
//        XCTAssertEqual(SIMD2<Float>(1, 2).map({ $0 * 2 }), [2, 4])
//        XCTAssertEqual(SIMD3<Float>(1, 2, 3).map({ $0 * 2 }), [2, 4, 6])
//        XCTAssertEqual(SIMD4<Float>(1, 2, 3, 4).map({ $0 * 2 }), [2, 4, 6, 8])
//        XCTAssertEqual(SIMD3<Float>(1, 2, 3).xy, [1, 2])
//        XCTAssertEqual(SIMD4<Float>(1, 2, 3, 4).xy, [1, 2])
//        XCTAssertEqual(SIMD4<Float>(1, 2, 3, 4).xyz, [1, 2, 3])
//    }
//
//    func testMatrix1() {
//        XCTAssertEqual(simd_float3x3(truncating: simd_float4x4(diagonal: [1, 2, 3, 4])), simd_float3x3(diagonal: [1, 2, 3]))
//    }
//
//    func testMatrix2() {
//        let m = simd_float4x4(diagonal: [1, 2, 3, 4])
//        let s = m.prettyDescription.removingOccurances(of: .whitespaces)
//        XCTAssertEqual(s, "1.0,0.0,0.0,0.0\n0.0,2.0,0.0,0.0\n0.0,0.0,3.0,0.0\n0.0,0.0,0.0,4.0")
//    }
//
//    func testMatrix3() {
//        let m = simd_float4x4(columns: ([1, 2, 3, 4], .zero, .zero, .zero))
//        let s = m.prettyDescription.removingOccurances(of: .whitespaces)
//        XCTAssertEqual(s, "1.0,0.0,0.0,0.0\n2.0,0.0,0.0,0.0\n3.0,0.0,0.0,0.0\n4.0,0.0,0.0,0.0")
//    }
//
//    func testMatrixRows() {
//        let m = simd_float4x4(rows: ([1, 2, 3, 4], .zero, .zero, .zero))
//        let s = m.prettyDescription.removingOccurances(of: .whitespaces)
//        XCTAssertEqual(s, "1.0,2.0,3.0,4.0\n0.0,0.0,0.0,0.0\n0.0,0.0,0.0,0.0\n0.0,0.0,0.0,0.0")
//    }
//
//    func testQuat() {
//        XCTAssertEqual(simd_quatf.identity, simd_quatf(angle: 0, axis: [0, 0, 0]))
//        XCTAssertEqual(simd_quatf.identity, simd_quatf(angle: 0, axis: [1, 0, 0]))
//        XCTAssertEqual(simd_quatf.identity, simd_quatf(angle: 0, axis: [0, 1, 0]))
//        XCTAssertEqual(simd_quatf.identity, simd_quatf(angle: 0, axis: [0, 0, 1]))
//    }
//}
//
//public extension String {
//    init<F>(_ input: F.FormatInput, format: F) where F : FormatStyle, F.FormatInput : Equatable, F.FormatOutput == String {
//        self = format.format(input)
//    }
//}
//
//
//
//class TempTest: XCTestCase {
//
//    func testX() {
//        print(simd_float4x4(translate: [10, 20, 30]).foo)
//    }
//
//    func testAPI() {
//        let scalars = Array(stride(from: Float(0), through: 15, by: 1))
//        XCTAssertEqual(simd_float4x4(scalars: scalars).scalars, scalars)
//    }
//
//}
//
//extension simd_float4x4 {
//
//    init(scalars: [Float]) {
//        assert(scalars.count == 16)
//        self.init(columns: (
//            SIMD4<Float>(scalars[0..<4]),
//            SIMD4<Float>(scalars[4..<8]),
//            SIMD4<Float>(scalars[8..<12]),
//            SIMD4<Float>(scalars[12...])
//        ))
//    }
//
//    var scalars: [Float] {
//        (0..<4).reduce(into: []) { result, column in
//            result += (0..<4).reduce(into: []) { result, row in
//                result.append(self[column][row])
//            }
//        }
//    }
//
//
//    var foo: String {
//        let format = FloatingPointFormatStyle<Float>()
//            .precision(.significantDigits(8))
//        let s = rows.map { row in
//            row.map { format.format($0) }
//            .joined(separator: ", ")
//        }
//        .joined(separator: "\n")
//        return s
//    }
//}
