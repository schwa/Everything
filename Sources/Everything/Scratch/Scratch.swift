import Foundation

// MARK: -

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
