////
////  File 2.swift
////
////
////  Created by Jonathan Wight on 4/6/20.
////
//
// import Foundation
//
// public protocol OutputStream {
//    mutating func write<T>(bytes: T) throws where T: Collection, T.Element == UInt8
//    mutating func write(_ value: String) throws
//    mutating func write<T>(_ value: T) throws
// }
//
// public class BinaryOutputStream<Buffer>: OutputStream where Buffer: RangeReplaceableCollection, Buffer.Element == UInt8 {
//    public private(set) var buffer: Buffer
//
//    public enum StringEncodingStrategy {
//        case undecorated
//        case nilTerminated
//        case lengthPrefixed
//        case custom((BinaryOutputStream<Buffer>, String) throws -> Void)
//    }
//
//    public var stringEncodingStrategy: StringEncodingStrategy = .undecorated
//    public var stringEncoding: String.Encoding = .utf8
//    public var allowLossyStringConversion: Bool = false
//
//    var current: Buffer.Index
//
//    public init(buffer: Buffer) {
//        self.buffer = buffer
//        current = buffer.startIndex
//    }
//
//    public func write<T>(bytes: T) throws where T: Collection, T.Element == UInt8 {
//        let end = buffer.index(current, offsetBy: bytes.count)
//        buffer.replaceSubrange(current ..< end, with: bytes)
//        current = end
//    }
//
//    public func write(_ value: String) throws {
//        switch stringEncodingStrategy {
//        case .undecorated:
//            guard let data = value.data(using: stringEncoding, allowLossyConversion: allowLossyStringConversion) else {
//                fatalError()
//            }
//            try write(bytes: data)
//        case .nilTerminated:
//            guard let data = value.data(using: stringEncoding, allowLossyConversion: allowLossyStringConversion) else {
//                fatalError()
//            }
//            try write(bytes: data)
//            try write(bytes: [UInt8(0)])
//        case .lengthPrefixed:
//            guard let data = value.data(using: stringEncoding, allowLossyConversion: allowLossyStringConversion) else {
//                fatalError()
//            }
//            guard data.count <= 255 else {
//                fatalError()
//            }
//            try write(bytes: [UInt8(data.count)])
//            try write(bytes: data)
//        case .custom(let custom):
//            try custom(self, value)
//        }
//    }
//
//    public func write<T>(_ value: T) throws {
//        try withUnsafeBytes(of: value) { bytes in
//            try write(bytes: bytes)
//        }
//    }
// }
