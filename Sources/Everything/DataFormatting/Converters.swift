import Foundation
import SwiftUI

public protocol Converter {
    associatedtype Value
    associatedtype Converted

    var convert: (Value) -> Converted { get }
    var reverse: (Converted) -> Value { get }
}

public struct FlippedConverter<C>: Converter where C: Converter {
    public typealias Value = C.Converted
    public typealias Converted = C.Value

    public let convert: (Value) -> Converted
    public let reverse: (Converted) -> Value

    public init(_ converter: C) {
        convert = converter.reverse
        reverse = converter.convert
    }
}

public extension Converter {
    var flipped: FlippedConverter<Self> {
        FlippedConverter(self)
    }
}

// TODO: Move
public extension Binding {
    func converting<C>(converter: C) -> Binding<C.Converted> where C: Converter & Sendable, C.Value == Value, Value: Sendable {
        Binding<C.Converted>(
            get: { converter.convert(self.wrappedValue) },
            set: { self.wrappedValue = converter.reverse($0) }
        )
    }
}
