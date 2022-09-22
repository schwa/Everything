import Foundation
import SwiftUI

public struct FormEncoder: Encoder {
    public var codingPath: [CodingKey] = []

    public var userInfo: [CodingUserInfoKey: Any] = [:]

    public init() {
    }

    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        KeyedEncodingContainer(MyKeyedEncodingContainer())
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        unimplemented()
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        unimplemented()
    }

    // MARK: -

    struct MyKeyedEncodingContainer<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {
        var codingPath: [CodingKey] = []

        var views: [AnyView] = []

        mutating func encodeNil(forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode(_ value: Bool, forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode(_ value: String, forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode(_ value: Double, forKey key: Key) throws {
            let view = HStack {
                Text(key.stringValue)
                Text(String(describing: value))
            }
            views.append(AnyView(view))
        }

        mutating func encode(_ value: Float, forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode(_ value: Int, forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode(_ value: Int8, forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode(_ value: Int16, forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode(_ value: Int32, forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode(_ value: Int64, forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode(_ value: UInt, forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode(_ value: UInt8, forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode(_ value: UInt16, forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode(_ value: UInt32, forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode(_ value: UInt64, forKey key: Key) throws {
            unimplemented()
        }

        mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
            unimplemented()
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
