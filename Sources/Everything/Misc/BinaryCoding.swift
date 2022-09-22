import Foundation

public struct BinaryEncoder {
    public init() {
    }

    public func encode<T>(_ value: T, into writer: OutputStream) throws where T: Encodable {
        let encoder = BinaryEncoder_(writer: writer)
        try value.encode(to: encoder)
    }

    // swiftlint:disable:next type_name
    struct BinaryEncoder_: Encoder {
        var codingPath: [CodingKey] = []

        var userInfo: [CodingUserInfoKey: Any] = [:]

        var writer: OutputStream

        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
            KeyedEncodingContainer(KeyedEncodingContainer_<Key>(writer: writer))
        }

        func unkeyedContainer() -> UnkeyedEncodingContainer {
            unimplemented()
        }

        func singleValueContainer() -> SingleValueEncodingContainer {
            unimplemented()
        }

        // swiftlint:disable:next type_name
        struct KeyedEncodingContainer_<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {
            var codingPath: [CodingKey] = []
            var writer: OutputStream

            mutating func encodeNil(forKey key: Key) throws {
                unimplemented()
            }

            mutating func encode(_ value: Bool, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode(_ value: String, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode(_ value: Double, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode(_ value: Float, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode(_ value: Int, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode(_ value: Int8, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode(_ value: Int16, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode(_ value: Int32, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode(_ value: Int64, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode(_ value: UInt, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode(_ value: UInt8, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode(_ value: UInt16, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode(_ value: UInt32, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode(_ value: UInt64, forKey key: Key) throws {
                try writer.write(value)
            }

            mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
                try writer.write(value)
            }

            mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
                unimplemented()
            }

            mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
                unimplemented()
            }

            mutating func superEncoder() -> Encoder {
                unimplemented()
            }

            mutating func superEncoder(forKey key: Key) -> Encoder {
                unimplemented()
            }
        }
    }
}
