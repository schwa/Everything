import Foundation

public struct Version {
    enum Error: Swift.Error {
        case invalidFormatString
    }

    public let major: UInt
    public let minor: UInt
    public let patch: UInt
    public let labels: [String]

    public init(major: UInt, minor: UInt, patch: UInt, labels: [String] = []) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.labels = labels
    }

    public init(_ tuple: (UInt, UInt, UInt), labels: [String] = []) {
        self = Version(major: tuple.0, minor: tuple.1, patch: tuple.2, labels: labels)
    }

    public var majorMinorPatch: (UInt, UInt, UInt) {
        (major, minor, patch)
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        "\(major).\(minor).\(patch)" + (labels.isEmpty ? "" : "-" + labels.joined(separator: "."))
    }
}

extension Version: Equatable {
    public static func == (lhs: Version, rhs: Version) -> Bool {
        compare(lhs, rhs) == .equal
    }
}

extension Version: Comparable {
    public static func < (lhs: Version, rhs: Version) -> Bool {
        compare(lhs, rhs) == .lesser
    }
}

public extension Version {
    init(_ string: String) throws {
        let scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = CharacterSet()

        var major: UInt = 0
        var minor: UInt = 0
        var patch: UInt = 0
        var labels: [String] = []

        var result = scanner.scanUnsignedInteger(&major)
        if result == false {
            throw Error.invalidFormatString
        }
        if scanner.scanString(".") != nil {
            result = scanner.scanUnsignedInteger(&minor)
            if result == false {
                throw Error.invalidFormatString
            }
            if scanner.scanString(".") != nil {
                result = scanner.scanUnsignedInteger(&patch)
                if result == false {
                    throw Error.invalidFormatString
                }
            }
            if scanner.scanString("-") != nil {
                let set = CharacterSet.alphanumerics + CharacterSet(charactersIn: "-")
                while true {
                    guard let label = scanner.scanCharacters(from: set) else {
                        throw Error.invalidFormatString
                    }
                    labels.append(label as String)
                    if scanner.scanString(".") == nil {
                        break
                    }
                }
            }
        }

        if scanner.isAtEnd == false {
            throw Error.invalidFormatString
        }

        self = Version(major: major, minor: minor, patch: patch, labels: labels)
    }
}

private extension String {
    var isNumeric: Bool {
        if isEmpty {
            return false
        }
        return unicodeScalars.allSatisfy {
            ("0" ... "9").contains($0)
        }
    }
}

private enum Label: Comparable {
    case string(String)
    case numeric(Int)
    case empty

    init(string: String) {
        if string.isEmpty {
            self = .empty
        }
        else if string.isNumeric {
            self = .numeric(Int(string)!)
        }
        else {
            self = .string(string)
        }
    }

    static func == (lhs: Label, rhs: Label) -> Bool {
        switch (lhs, rhs) {
        case (.string(let lhs), .string(let rhs)):
            return lhs == rhs
        case (.numeric(let lhs), .numeric(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }

    static func < (lhs: Label, rhs: Label) -> Bool {
        switch (lhs, rhs) {
        case (.string(let lhs), .string(let rhs)):
            return lhs < rhs
        case (.numeric(let lhs), .numeric(let rhs)):
            return lhs < rhs
        case (.empty, .numeric):
            return true
        case (.empty, .string):
            return true
        default:
            return false
        }
    }
}

public func compare(_ lhs: Version, _ rhs: Version) -> Comparison {
    var comparisons = [
        compare(lhs.major, rhs.major),
        compare(lhs.minor, rhs.minor),
        compare(lhs.patch, rhs.patch),
    ]
    let count = max(lhs.labels.count, rhs.labels.count)

    let lhsLabels = lhs.labels + repeatElement("", count: count - lhs.labels.count)
    let rhsLabels = rhs.labels + repeatElement("", count: count - rhs.labels.count)
    comparisons += zip(lhsLabels.map(Label.init), rhsLabels.map(Label.init)).map(compare)
    for comparison in comparisons where comparison != .equal {
        return comparison
    }
    return .equal
}

private extension Scanner {
    func scanUnsignedInteger(_ result: UnsafeMutablePointer<UInt>?) -> Bool {
        var value: UInt64 = 0
        guard scanUnsignedLongLong(&value) == true else {
            return false
        }
        if result != nil {
            result?.pointee = UInt(value)
        }
        return true
    }
}
