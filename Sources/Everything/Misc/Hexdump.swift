import Foundation

// TODO: Remove Buffer.index == Int restriction
// swiftlint:disable:next line_length
public func hexdump<Buffer, Target: TextOutputStream>(_ buffer: Buffer, width: Int = 16, baseAddress: Int = 0, separator: String = "\n", terminator: String = "", stream: inout Target) where Buffer: RandomAccessCollection, Buffer.Element == UInt8, Buffer.Index == Int {
    for index in stride(from: 0, through: buffer.count, by: width) {
        let address = UInt(baseAddress + index).format(radix: 16, leadingZeros: true)
        let chunk = buffer[index ..< (index + min(width, buffer.count - index))]
        if chunk.isEmpty {
            break
        }
        let hex = chunk.map {
            $0.format(radix: 16, leadingZeros: true)
        }
        .joined(separator: " ")
        let paddedHex = hex.padding(toLength: width * 3 - 1, withPad: " ", startingAt: 0)

        let string = chunk.map { (c: UInt8) -> String in
            let scalar = UnicodeScalar(c)

            let character = Character(scalar)
            if isprint(Int32(c)) != 0 {
                return String(character)
            }
            else {
                return "?"
            }
        }
        .joined()

        stream.write("\(address)  \(paddedHex)  \(string)")
        stream.write(separator)
    }
    stream.write(terminator)
}

public func hexdump<Buffer>(_ buffer: Buffer, width: Int = 16, baseAddress: Int = 0) where Buffer: RandomAccessCollection, Buffer.Element == UInt8, Buffer.Index == Int {
    var string = String()
    hexdump(buffer, width: width, baseAddress: baseAddress, stream: &string)
    print(string)
}
