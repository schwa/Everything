// public protocol BinaryOutputStream {
//    mutating func append(_ value: UInt8)
//    mutating func append(_ value: UnsafeBufferPointer<UInt8>)
//    mutating func append(_ value: UnsafeRawBufferPointer)
// }
//
//// TODO: We can just make Data/Array<UInt8> conform to this
// public class Output: BinaryOutputStream {
//    public var bytes: [UInt8] = []
//
//    public func append(_ value: UInt8) {
//        bytes.append(value)
//    }
//
//    public func append(_ value: UnsafeBufferPointer<UInt8>) {
//        bytes += value
//    }
//
//    public func append(_ value: UnsafeRawBufferPointer) {
//        append(value.bindMemory(to: UInt8.self))
//    }
// }

// extension Output: CustomStringConvertible {
//    public var description: String {
//        return String(describing: bytes)
//    }
// }

public protocol OutputStream {
    mutating func write<T>(bytes: T) throws where T: Collection, T.Element == UInt8
    mutating func write(_ value: String) throws
    mutating func write<T>(_ value: T) throws
}

public class BinaryOutputStream<Buffer>: OutputStream where Buffer: RangeReplaceableCollection, Buffer.Element == UInt8 {
    public private(set) var buffer: Buffer

    public enum StringEncodingStrategy {
        case undecorated
        case nilTerminated
        case lengthPrefixed
        case custom((BinaryOutputStream<Buffer>, String) throws -> Void)
    }

    public var stringEncodingStrategy: StringEncodingStrategy = .undecorated
    public var stringEncoding: String.Encoding = .utf8
    public var allowLossyStringConversion = false

    var current: Buffer.Index

    public init(buffer: Buffer) {
        self.buffer = buffer
        current = buffer.startIndex
    }

    public func write(bytes: some Collection<UInt8>) throws {
        let end = buffer.index(current, offsetBy: bytes.count)
        buffer.replaceSubrange(current ..< end, with: bytes)
        current = end
    }

    public func write(_ value: String) throws {
        switch stringEncodingStrategy {
        case .undecorated:
            guard let data = value.data(using: stringEncoding, allowLossyConversion: allowLossyStringConversion) else {
                throw GeneralError.valueConversionFailure
            }
            try write(bytes: data)
        case .nilTerminated:
            guard let data = value.data(using: stringEncoding, allowLossyConversion: allowLossyStringConversion) else {
                throw GeneralError.valueConversionFailure
            }
            try write(bytes: data)
            try write(bytes: [UInt8(0)])
        case .lengthPrefixed:
            guard let data = value.data(using: stringEncoding, allowLossyConversion: allowLossyStringConversion) else {
                throw GeneralError.valueConversionFailure
            }
            guard data.count <= 255 else {
                throw GeneralError.valueConversionFailure
            }
            try write(bytes: [UInt8(data.count)])
            try write(bytes: data)
        case .custom(let custom):
            try custom(self, value)
        }
    }

    public func write(_ value: some Any) throws {
        try withUnsafeBytes(of: value) { bytes in
            try write(bytes: bytes)
        }
    }
}
