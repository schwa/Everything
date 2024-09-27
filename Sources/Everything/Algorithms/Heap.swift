import Foundation

// https://en.wikipedia.org/wiki/Binary_heap
public struct BinaryHeap<Element> {
    public typealias Comparator = (Element, Element) -> Bool
    public let comparator: Comparator

    public typealias Storage = [Element]
    public var array: Storage = []

    public init(comparator: @escaping Comparator) {
        self.comparator = comparator
    }

    public init(values: [Element], comparator: @escaping Comparator) {
        array = values
        self.comparator = comparator
        build(&array)
    }

    public var count: Int {
        array.count
    }

    public mutating func push(_ element: Element) {
        assert(valid(array))
        var index = array.count
        array.append(element)
        while let parentIndex = parentIndexOfElementAtIndex(index) {
            if comparator(array[index], array[parentIndex]) {
                array.swapAt(index, parentIndex)
                index = parentIndex
            } else {
                break
            }
        }
        assert(valid(array))
    }

    public mutating func pop() -> Element? {
        assert(valid(array))
        guard let root = array.first else {
            return nil
        }
        array[0] = array.last!
        array.removeLast()
        heapify(0)
        assert(valid(array))
        return root
    }

    public var isEmpty: Bool {
        array.isEmpty
    }
}

private extension BinaryHeap {
    func parentIndexOfElementAtIndex(_ index: Int) -> Int? {
        index < array.count ? (index - 1) / 2 : nil
    }

    func childIndicesOfElementAtIndex(_ index: Int) -> (Int?, Int?) {
        let lhsIndex = 2 * index + 1
        let rhsIndex = 2 * index + 2
        return (lhsIndex < array.count ? lhsIndex : nil, rhsIndex < array.count ? rhsIndex : nil)
    }

    mutating func heapify(_ index: Int) {
        heapify(&array, index)
    }

    func heapify(_ elements: inout [Element], _ index: Int) {
        let left = 2 * index + 1
        let right = 2 * index + 2
        var largest = index
        if left < elements.count, comparator(elements[left], elements[largest]) {
            largest = left
        }
        if right < elements.count, comparator(elements[right], elements[largest]) {
            largest = right
        }
        if largest != index {
            elements.swapAt(index, largest)
            heapify(&elements, largest)
        }
    }

    // TODO: Not working yet.
    func build(_ elements: inout [Element]) {
        assertionFailure()

        for i in stride(from: elements.count - 1, through: 0, by: -1) {
            heapify(&elements, i)
        }
    }

    func valid(_ elements: [Element], index: Int = 0) -> Bool {
        guard !elements.isEmpty else {
            return true
        }
        let (lhs, rhs) = childIndicesOfElementAtIndex(index)
        if let lhs {
            if comparator(elements[lhs], elements[index]) {
                return false
            }
            if !valid(elements, index: lhs) {
                return false
            }
        }
        if let rhs {
            if comparator(elements[rhs], elements[index]) {
                return false
            }
            if !valid(elements, index: rhs) {
                return false
            }
        }
        return true
    }
}
