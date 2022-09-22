import Foundation

public struct RegularExpression {
    public let pattern: String
    public let expression: NSRegularExpression

    public init(_ pattern: String, options: NSRegularExpression.Options = NSRegularExpression.Options()) throws {
        self.pattern = pattern
        expression = try NSRegularExpression(pattern: pattern, options: options)
    }

    public func search(_ string: String, options: NSRegularExpression.MatchingOptions = NSRegularExpression.MatchingOptions()) -> Match? {
        let length = (string as NSString).length
        guard let result = expression.firstMatch(in: string, options: options, range: NSRange(location: 0, length: length)) else {
            return nil
        }
        return Match(string: string, result: result)
    }

    public func searchAll(_ string: String, options: NSRegularExpression.MatchingOptions = NSRegularExpression.MatchingOptions()) -> [Match] {
        let length = (string as NSString).length
        let result = expression.matches(in: string, options: options, range: NSRange(location: 0, length: length))

        return result.map {
            Match(string: string, result: $0)
        }
    }

    public func match(_ string: String, options: NSRegularExpression.MatchingOptions = NSRegularExpression.MatchingOptions()) -> Match? {
        guard let match = search(string, options: options) else {
            return nil
        }
        let firstRange = match.ranges[0]
        if firstRange.lowerBound != string.startIndex {
            return nil
        }
        return match
    }

    // Other ideas from https://docs.python.org/2/library/re.html
    // split, findall, finditer, sub

    public struct Match: CustomStringConvertible {
        public let string: String
        public let result: NSTextCheckingResult

        init(string: String, result: NSTextCheckingResult) {
            self.string = string
            self.result = result
        }

        public var description: String {
            "Match(\(result.numberOfRanges))"
        }

        public var ranges: [Range<String.Index>] {
            let count = result.numberOfRanges
            let ranges: [Range<String.Index>] = (0 ..< count).map {
                let nsRange = result.range(at: $0)
                let range = Range(nsRange, in: string)
                return range!
            }
            return ranges
        }

        public var strings: [String?] {
            let count = result.numberOfRanges
            let groups: [String?] = (0 ..< count).map {
                let range = self.result.range(at: $0)
                if range.location == NSNotFound {
                    return nil
                }
                return (self.string as NSString).substring(with: range)
            }
            return groups
        }
    }
}

public extension RegularExpression {
    static func ~= (pattern: RegularExpression, value: String) -> Bool {
        let match = pattern.search(value)
        return match != nil
    }
}

public extension NSTextCheckingResult {
    func namedGroups(in string: String, names: [String]) -> [String: String] {
        names.reduce(into: [:]) { dictionary, name in
            let nsRange = range(withName: name)
            guard nsRange.location != NSNotFound, let range = Range(nsRange, in: string) else {
                return
            }
            dictionary[name] = String(string[range])
        }
    }
}

public extension NSRegularExpression {
    func firstMatch(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil) -> NSTextCheckingResult? {
        let nsRange: NSRange
        if let range {
            nsRange = NSRange(range, in: string)
        }
        else {
            nsRange = NSRange(string.startIndex ..< string.endIndex, in: string)
        }
        return firstMatch(in: string, options: options, range: nsRange)
    }
}
