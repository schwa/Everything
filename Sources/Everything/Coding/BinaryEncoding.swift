import Foundation

public func encode(_ N: UInt64) -> [UInt8] {
    var result: [UInt8] = []
    var N = N
    repeat {
        let byte = UInt8(N & 0b0111_1111)
        N = N >> 7
        print(N)
        result.insert(byte | (N != 0 ? 128 : 0), at: 0)
    }
    while N > 0
    return result
}
