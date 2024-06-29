import Foundation

@inlinable
public func signExtend(_ n: UInt32, bits: Int) -> Int32 {
    let signed = (n & 1 << (bits - 1)) != 0
    if !signed {
        return Int32(truncatingIfNeeded: n)
    }
    let ones = UInt32.max << bits
    return Int32(bitPattern: ones | n)
}

@inlinable
public func signExtendU(_ n: UInt32, bits: Int) -> UInt32 {
    // TODO: this is a bit silly
    UInt32(bitPattern: signExtend(n, bits: bits))
}

public extension Array {
    func rebind<T>(to: T.Type) -> [T] {
        withUnsafeBufferPointer { buffer in
            let capacity = (count * MemoryLayout<Element>.stride) / MemoryLayout<T>.stride

            return buffer.withMemoryRebound(to: T.self, capacity: capacity) { buffer in
                [T](buffer)
            }
        }
    }
}
