import Foundation

public struct IntegerStringFormatter {
    let radix: Int
    let prefix: Prefix
    let width: Width
    let paddingCharacter: Character
    let groupCount: Int?
    let groupSeparator: String
    let uppercase: Bool

    public enum Prefix {
        case none
        case standard
        case custom(String)
    }

    public enum Width {
        case minimum
        case byType
        case count(Int)
    }

    public init(radix: Int, prefix: Prefix = .none, leadingZeros: Bool = false, groupCount: Int? = nil, groupSeparator: String = "_", uppercase: Bool = false) {
        self.radix = radix
        self.prefix = prefix
        width = leadingZeros ? .byType : .minimum
        paddingCharacter = "0"
        self.groupCount = groupCount
        self.groupSeparator = groupSeparator
        self.uppercase = uppercase
    }

    public init(radix: Int, prefix: Prefix = .none, width: Width, paddingCharacter: Character = "0", groupCount: Int? = nil, groupSeparator: String = "_", uppercase: Bool = false) {
        self.radix = radix
        self.prefix = prefix
        self.width = width
        self.paddingCharacter = paddingCharacter
        self.groupCount = groupCount
        self.groupSeparator = groupSeparator
        self.uppercase = uppercase
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public func format<T>(_ value: T) -> String where T: BinaryInteger {
        var digits = String(value, radix: radix, uppercase: uppercase)

        switch width {
        case .minimum:
            break
        case .byType:
            let bitsPerCharacter: Int
            switch radix {
            case 2:
                bitsPerCharacter = 1
            case 8:
                bitsPerCharacter = 3
            case 16:
                bitsPerCharacter = 4
            default:
                unimplemented()
            }
            if bitsPerCharacter != 0 {
                let maxDigits = MemoryLayout<T>.size * 8 / bitsPerCharacter
                let leadingPaddingCount = maxDigits - digits.count
                if leadingPaddingCount > 0 {
                    digits.insert(contentsOf: repeatElement(paddingCharacter, count: leadingPaddingCount), at: digits.startIndex)
                }
            }
        case .count(let count):
            let leadingPaddingCount = count - digits.count
            if leadingPaddingCount > 0 {
                digits.insert(contentsOf: repeatElement(paddingCharacter, count: leadingPaddingCount), at: digits.startIndex)
            }
            digits = String(digits.suffix(count))
        }

        if let groupCount {
            digits = digits.split(by: groupCount, includeIncomplete: true, reversed: true).reversed().joined(separator: groupSeparator)
        }

        switch (prefix, radix) {
        case (.none, _):
            break
        case (.standard, 2):
            digits = "0b" + digits
        case (.standard, 8):
            digits = "0o" + digits
        case (.standard, 16):
            digits = "0x" + digits
        case (.custom(let prefix), _):
            digits = prefix + digits
        default:
            // fatalError("No standard prefix for radix \(radix)")
            break
        }

        return digits
    }
}

public extension BinaryInteger {
    func format(radix: Int, prefix: IntegerStringFormatter.Prefix = .none, leadingZeros: Bool = false, groupCount: Int? = nil, groupSeparator: String = "_", uppercase: Bool = false) -> String {
        let formatter = IntegerStringFormatter(radix: radix, prefix: prefix, leadingZeros: leadingZeros, groupCount: groupCount, groupSeparator: groupSeparator, uppercase: uppercase)
        return formatter.format(self)
    }

    var hexString: String {
        format(radix: 16, prefix: .standard, leadingZeros: true, groupCount: nil, groupSeparator: "_", uppercase: true)
    }
}
