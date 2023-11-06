import Foundation

// MARK: -

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(string: value)!
    }
}

extension URL: ExpressibleByStringInterpolation {
}

public struct WeakBox<Content> where Content: AnyObject {
    public weak var content: Content?

    public init(_ content: Content) {
        self.content = content
    }
}

// TODO: Move

public extension UInt8 {
    init(character: Character) {
        assert(character.utf8.count == 1)
        self = character.utf8.first!
    }
}

public extension AsyncSequence {
    func cast <T>(to: T.Type) -> AsyncCompactMapSequence<Self, T?> {
        compactMap { $0 as? T }
    }
}

/// An object that provides access to the bytes of a value.
/// Avoids issues where getting the bytes of an onject cast to Any is not the same as getting the bytes to the object
public struct UnsafeBytesAccessor: Sendable {
    private let closure: @Sendable (@Sendable (UnsafeRawBufferPointer) -> Void) -> Void

    public init(_ value: some Any) {
        closure = { (callback: (UnsafeRawBufferPointer) -> Void) in
            Swift.withUnsafeBytes(of: value) { buffer in
                callback(buffer)
            }
        }
    }

    public init(_ value: [some Any]) {
        closure = { (callback: (UnsafeRawBufferPointer) -> Void) in
            value.withUnsafeBytes { buffer in
                callback(buffer)
            }
        }
    }

    public func withUnsafeBytes(_ body: @Sendable (UnsafeRawBufferPointer) -> Void) {
        closure(body)
    }
}
