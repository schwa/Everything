import Foundation

/**
 ```swift doctest
 align(0, 0) // => Int = 0
 ```
 */
public func align(offset: Int, alignment: Int) -> Int {
    // https://en.wikipedia.org/wiki/Data_structure_alignment
    let alignment = alignment == 0 ? MemoryLayout<Int>.size : alignment
    return offset + ((alignment - (offset % alignment)) % alignment)
}
