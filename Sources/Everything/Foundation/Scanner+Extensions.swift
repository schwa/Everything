import Foundation

public extension Scanner {
    var remaining: Substring {
        string[currentIndex...]
    }

    func scan(regularExpression pattern: String) throws -> NSTextCheckingResult? {
        let expression = try NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(currentIndex ..< string.endIndex, in: string)

        guard let match = expression.firstMatch(in: string, options: [], range: range) else {
            return nil
        }
        currentIndex = Range<String.Index>(match.range, in: string)!.upperBound
        return match
    }

    var infographic: String {
        "[\(scanned)] <|> [\(remaining)]"
    }

    var scanned: Substring {
        string[..<currentIndex]
    }

    func scanQuotedEscapedString() -> String? {
        //        print("1", Scanner(string: #""kMDItemCFBundleIdentifier == 'com.apple.dt.Xcode' && kMDItemContentType == 'com.apple.application-bundle'""#).scanQuotedEscapedString())

        //        print("1", Scanner(string: #"hello world"#).scanQuotedEscapedString())
        //        print("2", Scanner(string: #""hello world""#).scanQuotedEscapedString())
        //        print("3", Scanner(string: #""hello \" world""#).scanQuotedEscapedString())
        //        print("3", Scanner(string: #""hello \"\" world""#).scanQuotedEscapedString())
        //        print("4", Scanner(string: #""hello world"#).scanQuotedEscapedString())
        //        print("5", Scanner(string: #"hello "world"#).scanQuotedEscapedString())
        //        print("6", Scanner(string: #"hello world""#).scanQuotedEscapedString())

        let savedIndex = currentIndex
        var recover = Optional {
            self.currentIndex = savedIndex
        }
        defer {
            recover?()
        }

        guard scanString("\"") == "\"" else {
            return nil
        }
        var result = ""
        while isAtEnd == false {
            guard let s = scanUpToCharacters(from: CharacterSet(charactersIn: "\"\\")) else {
                fatalError("This should not be possible.")
            }
            result.append(s)

            let c = scanCharacter()

            switch c {
            case "\\":
                let c = scanCharacter()
                switch c {
                case "\"":
                    result.append("\"")
                default:
                    fatalError("Unknown escape code: \(String(describing: c))")
                }
            case "\"":
                break
            default:
                return nil
            }
        }

        recover = nil
        return result
    }
}
