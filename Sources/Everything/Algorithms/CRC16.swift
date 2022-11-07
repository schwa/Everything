import Foundation

// CRC-16-CCITT	X.25

// TODO: Use DataProtocol

public struct CRC16 {
    public typealias CRCType = UInt16
    public internal(set) var crc: CRCType!

    public init() {}

    public static func accumulate(_ buffer: UnsafeBufferPointer<UInt8>, crc: CRCType = 0xFFFF) -> CRCType {
        var accum = crc
        for b in buffer {
            var tmp = CRCType(b) ^ (accum & 0xFF)
            tmp = (tmp ^ (tmp << 4)) & 0xFF
            accum = (accum >> 8) ^ (tmp << 8) ^ (tmp << 3) ^ (tmp >> 4)
        }
        return accum
    }

    public mutating func accumulate(_ buffer: UnsafeBufferPointer<UInt8>) {
        if crc == nil {
            crc = 0xFFFF
        }
        crc = CRC16.accumulate(buffer, crc: crc)
    }
}

public extension CRC16 {
    mutating func accumulate(_ bytes: [UInt8]) {
        bytes.withUnsafeBufferPointer { (body: UnsafeBufferPointer<UInt8>) in
            accumulate(body)
        }
    }

    mutating func accumulate(_ string: String) {
        string.withCString { (ptr: UnsafePointer<Int8>) in
            let count = Int(strlen(ptr))
            ptr.withMemoryRebound(to: UInt8.self, capacity: count) { ptr in
                let buffer = UnsafeBufferPointer<UInt8>(start: ptr, count: count)
                accumulate(buffer)
            }
        }
    }
}
