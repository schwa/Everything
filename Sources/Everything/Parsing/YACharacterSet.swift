import Foundation

public struct YACharacterSet: Sendable {
    public let set: Set<Character>

    public init(_ set: Set<Character>) {
        self.set = set
    }

    public init(_ characters: [Character]) {
        set = Set(characters)
    }

    public init(charactersIn string: String) {
        set = Set(string)
    }

    public func contains(_ member: Character) -> Bool {
        set.contains(member)
    }

    public static let asciiWhitespaces = Self(charactersIn: " \t\n\r")
    public static let whitespaces = asciiWhitespaces

    public static let decimalDigits = Self(charactersIn: "0123456789")
}

extension YACharacterSet {
    static func + (lhs: YACharacterSet, rhs: YACharacterSet) -> YACharacterSet {
        YACharacterSet(lhs.set.union(rhs.set))
    }
}

//    public class func controlCharacterSet() -> NSCharacterSet
//    public class func whitespaceCharacterSet() -> NSCharacterSet
//    public class func whitespaceAndNewlineCharacterSet() -> NSCharacterSet
//    public class func decimalDigitCharacterSet() -> NSCharacterSet
//    public class func letterCharacterSet() -> NSCharacterSet
//    public class func lowercaseLetterCharacterSet() -> NSCharacterSet
//    public class func uppercaseLetterCharacterSet() -> NSCharacterSet
//    public class func nonBaseCharacterSet() -> NSCharacterSet
//    public class func alphanumericCharacterSet() -> NSCharacterSet
//    public class func decomposableCharacterSet() -> NSCharacterSet
//    public class func illegalCharacterSet() -> NSCharacterSet
//    public class func punctuationCharacterSet() -> NSCharacterSet
//    public class func capitalizedLetterCharacterSet() -> NSCharacterSet
//    public class func symbolCharacterSet() -> NSCharacterSet
//    @available(OSX 10.5, *)
//    public class func newlineCharacterSet() -> NSCharacterSet
