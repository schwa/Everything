import Foundation

public struct PriorityQueue<Element, Priority: Comparable> {
    public var binaryHeap: BinaryHeap<(Element, Priority)>

    public init() {
        binaryHeap = BinaryHeap<(Element, Priority)> {
            $0.1 < $1.1
        }
    }

    public var count: Int {
        binaryHeap.count
    }

    public var isEmpty: Bool {
        binaryHeap.isEmpty
    }

    public mutating func get() -> Element? {
        guard let (element, _) = binaryHeap.pop() else {
            return nil
        }
        return element
    }

    public mutating func put(_ element: Element, priority: Priority) {
        binaryHeap.push((element, priority))
    }
}

extension PriorityQueue: Sequence {
    public typealias Iterator = PriorityQueueGenerator<Element, Priority>
    public func makeIterator() -> Iterator {
        Iterator(queue: self)
    }
}

public struct PriorityQueueGenerator<Value, Priority: Comparable>: IteratorProtocol {
    public typealias Element = Value
    internal var queue: PriorityQueue<Value, Priority>
    public init(queue: PriorityQueue<Value, Priority>) {
        self.queue = queue
    }

    public mutating func next() -> Element? {
        queue.get()
    }
}
