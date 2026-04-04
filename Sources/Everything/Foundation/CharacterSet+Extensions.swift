import Foundation

public extension CharacterSet {
    static let hexdigits = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
}

public extension CharacterSet {
    static func + (lhs: CharacterSet, rhs: CharacterSet) -> CharacterSet {
        lhs.union(rhs)
    }
}

public extension CharacterSet {
    static func ~= (lhs: CharacterSet, rhs: Character) -> Bool {
        guard let first = rhs.unicodeScalars.first else {
            fatalError("Character has no unicode scalars")
        }
        return lhs.contains(first)
    }
}
