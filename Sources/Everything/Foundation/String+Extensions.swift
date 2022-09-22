import Foundation

public extension String {
    // TODO: Don't throw.
    func substringFromPrefix(_ prefix: String) throws -> Substring {
        if prefix.isEmpty {
            return self[...]
        }
        if let range = range(of: prefix), range.lowerBound == startIndex {
            return self[range.upperBound...]
        }
        throw GeneralError.generic("String does not begin with prefix.")
    }
}

public extension String {
    func removingOccurances(of characterSet: CharacterSet) -> String {
        var result = ""
        let scanner = Scanner(string: self)
        scanner.charactersToBeSkipped = characterSet
        while scanner.isAtEnd == false {
            if let chunk = scanner.scanUpToCharacters(from: characterSet) {
                result.append(chunk)
            }
        }
        return result
    }
}

public extension StringProtocol {
    var isUppercase: Bool {
        // TODO: This is very error prone perhaps?
        self == uppercased()
    }

    var isPrintable: Bool {
        let set = CharacterSet.controlCharacters

        return firstIndex { set.contains($0) } == nil
    }
}

extension CharacterSet {
    func contains(_ member: Character) -> Bool {
        for scalar in member.unicodeScalars {
            // TODO: this is a bit iffy. Reverse this logic?
            if contains(scalar) {
                return true
            }
        }
        return false
    }
}

public extension CharacterSet {
    static func ~= (lhs: CharacterSet, rhs: Character) -> Bool {
        lhs.contains(rhs.unicodeScalars.first!)
    }
}

public extension Character {
    static let escape = Character("\u{1B}")
}

public extension String.Encoding {
    init(contentsOf url: URL) throws {
        var encoding: String.Encoding = .ascii
        _ = try String(contentsOf: url, usedEncoding: &encoding)
        self = encoding
    }
}

public extension String {
    init<F>(_ input: F.FormatInput, format: F) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
        self = format.format(input)
    }
}
