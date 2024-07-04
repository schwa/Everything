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
        lhs.contains(rhs.unicodeScalars.first!)
    }
}
