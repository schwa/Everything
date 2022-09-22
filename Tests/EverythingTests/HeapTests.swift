@testable import Everything
import Foundation
import XCTest

class HeapTests: XCTestCase {
    func test1() {
        var heap = BinaryHeap<Int>(comparator: <)
        heap.push(100)
        XCTAssertEqual(heap.array, [100])
        heap.push(200)
        XCTAssertEqual(heap.array, [100, 200])
        XCTAssertEqual(heap.pop()!, 100)
        XCTAssertEqual(heap.pop()!, 200)
    }

    func test2() {
        var heap = BinaryHeap<Int>(comparator: <)
        heap.push(4)
        heap.push(7)
        heap.push(9)
        heap.push(0)
        heap.push(1)
        heap.push(0)
        XCTAssertEqual(heap.pop()!, 0)
        XCTAssertEqual(heap.pop()!, 0)
        XCTAssertEqual(heap.pop()!, 1)
        XCTAssertEqual(heap.pop()!, 4)
        XCTAssertEqual(heap.pop()!, 7)
        XCTAssertEqual(heap.pop()!, 9)
    }
}
