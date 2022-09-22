@testable import Everything
import Foundation
import XCTest

class RandomTests: XCTestCase {
    func test1() {
        let weights: [Float] = [10]
        XCTAssertEqual(weights.weightedRandomIndex(), weights.startIndex)
    }

    func test2() {
        let weights: [Double] = [10]
        XCTAssertEqual(weights.weightedRandomIndex(), weights.startIndex)
    }

    func test3() {
        let weights: [Double] = [10, 0]
        XCTAssertEqual(weights.weightedRandomIndex(), weights.startIndex)
    }

    func test4() {
        let weights: [Double] = [10, 0, 0]
        XCTAssertEqual(weights.weightedRandomIndex(), weights.startIndex)
    }

    func test5() {
        let weights: [Double] = [10, 0, 0]
        let index = weights.weightedRandomIndex()
        XCTAssertEqual(weights[index], 10)
    }

    func test6() {
        let weights: [Double] = [0, 10, 0]
        let index = weights.weightedRandomIndex()
        XCTAssertEqual(weights[index], 10)
    }

    func test7() {
        let weights: [Double] = [0, 0, 10]
        let index = weights.weightedRandomIndex()
        XCTAssertEqual(weights[index], 10)
    }
}
