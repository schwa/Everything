import Foundation

public struct RadixedIntegerFormatStyle<FormatInput>: FormatStyle, Hashable, Codable where FormatInput: BinaryInteger {
    public typealias FormatInput = FormatInput
    public typealias FormatOutput = String

    private var radix: Int
    private var prefix: Prefix
    private var width: Width
    private var padding: Character
    private var groupCount: Int?
    private var groupSeparator: String
    private var uppercase: Bool

    public enum Prefix: Hashable, Codable {
        case none
        case standard
        case custom(String)
    }

    public enum Width: Hashable, Codable {
        case minimum
        case byType
        case count(Int)
    }

    public init(radix: Int = 10, prefix: Prefix = .none, width: Width, padding: Character = "0", groupCount: Int? = nil, groupSeparator: String = "_", uppercase: Bool = false) {
        self.radix = radix
        self.prefix = prefix
        self.width = width
        self.padding = padding
        self.groupCount = groupCount
        self.groupSeparator = groupSeparator
        self.uppercase = uppercase
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public func format(_ value: FormatInput) -> String {
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
                let maxDigits = MemoryLayout<FormatInput>.size * 8 / bitsPerCharacter
                let leadingPaddingCount = maxDigits - digits.count
                if leadingPaddingCount > 0 {
                    digits.insert(contentsOf: repeatElement(padding, count: leadingPaddingCount), at: digits.startIndex)
                }
            }
        case .count(let count):
            let leadingPaddingCount = count - digits.count
            if leadingPaddingCount > 0 {
                digits.insert(contentsOf: repeatElement(padding, count: leadingPaddingCount), at: digits.startIndex)
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

public extension RadixedIntegerFormatStyle {
    init(radix: Int = 10, prefix: Prefix = .none, leadingZeros: Bool = false, groupCount: Int? = nil, groupSeparator: String = "_", uppercase: Bool = false) {
        self = .init(radix: radix, prefix: prefix, width: leadingZeros ? .byType : .minimum, padding: "0", groupCount: groupCount, groupSeparator: groupSeparator, uppercase: uppercase)
    }
}

// MARK: -

public extension RadixedIntegerFormatStyle {
    // TODO: Add more styling functions here
    func group(_ count: Int, separator: String = "_") -> Self {
        var copy = self
        copy.groupCount = count
        copy.groupSeparator = separator
        return copy
    }

    func leadingZeros(_ leadingZeros: Bool = true) -> Self {
        var copy = self
        copy.width = leadingZeros ? .byType : .minimum
        copy.padding = "0"
        return copy
    }
}

// MARK: -

public extension FormatStyle where Self == RadixedIntegerFormatStyle<Int> {
    static var hex: Self {
        Self(radix: 16, prefix: .standard, leadingZeros: false, groupCount: nil, uppercase: true)
    }

    static var binary: Self {
        Self(radix: 2, prefix: .standard, leadingZeros: false, groupCount: nil)
    }

    static var octal: Self {
        Self(radix: 8, prefix: .standard, leadingZeros: false, groupCount: nil)
    }
}

public extension FormatStyle where Self == RadixedIntegerFormatStyle<Int8> {
    static var hex: Self {
        Self(radix: 16, prefix: .standard, leadingZeros: false, groupCount: nil, uppercase: true)
    }

    static var binary: Self {
        Self(radix: 2, prefix: .standard, leadingZeros: false, groupCount: nil)
    }

    static var octal: Self {
        Self(radix: 8, prefix: .standard, leadingZeros: false, groupCount: nil)
    }
}

public extension FormatStyle where Self == RadixedIntegerFormatStyle<Int16> {
    static var hex: Self {
        Self(radix: 16, prefix: .standard, leadingZeros: false, groupCount: nil, uppercase: true)
    }

    static var binary: Self {
        Self(radix: 2, prefix: .standard, leadingZeros: false, groupCount: nil)
    }

    static var octal: Self {
        Self(radix: 8, prefix: .standard, leadingZeros: false, groupCount: nil)
    }
}

public extension FormatStyle where Self == RadixedIntegerFormatStyle<Int32> {
    static var hex: Self {
        Self(radix: 16, prefix: .standard, leadingZeros: false, groupCount: nil, uppercase: true)
    }

    static var binary: Self {
        Self(radix: 2, prefix: .standard, leadingZeros: false, groupCount: nil)
    }

    static var octal: Self {
        Self(radix: 8, prefix: .standard, leadingZeros: false, groupCount: nil)
    }
}

public extension FormatStyle where Self == RadixedIntegerFormatStyle<Int64> {
    static var hex: Self {
        Self(radix: 16, prefix: .standard, leadingZeros: false, groupCount: nil, uppercase: true)
    }

    static var binary: Self {
        Self(radix: 2, prefix: .standard, leadingZeros: false, groupCount: nil)
    }

    static var octal: Self {
        Self(radix: 8, prefix: .standard, leadingZeros: false, groupCount: nil)
    }
}

public extension FormatStyle where Self == RadixedIntegerFormatStyle<UInt> {
    static var hex: Self {
        Self(radix: 16, prefix: .standard, leadingZeros: false, groupCount: nil, uppercase: true)
    }

    static var binary: Self {
        Self(radix: 2, prefix: .standard, leadingZeros: false, groupCount: nil)
    }

    static var octal: Self {
        Self(radix: 8, prefix: .standard, leadingZeros: false, groupCount: nil)
    }
}

public extension FormatStyle where Self == RadixedIntegerFormatStyle<UInt8> {
    static var hex: Self {
        Self(radix: 16, prefix: .standard, leadingZeros: false, groupCount: nil, uppercase: true)
    }

    static var binary: Self {
        Self(radix: 2, prefix: .standard, leadingZeros: false, groupCount: nil)
    }

    static var octal: Self {
        Self(radix: 8, prefix: .standard, leadingZeros: false, groupCount: nil)
    }
}

public extension FormatStyle where Self == RadixedIntegerFormatStyle<UInt16> {
    static var hex: Self {
        Self(radix: 16, prefix: .standard, leadingZeros: false, groupCount: nil, uppercase: true)
    }

    static var binary: Self {
        Self(radix: 2, prefix: .standard, leadingZeros: false, groupCount: nil)
    }

    static var octal: Self {
        Self(radix: 8, prefix: .standard, leadingZeros: false, groupCount: nil)
    }
}

public extension FormatStyle where Self == RadixedIntegerFormatStyle<UInt32> {
    static var hex: Self {
        Self(radix: 16, prefix: .standard, leadingZeros: false, groupCount: nil, uppercase: true)
    }

    static var binary: Self {
        Self(radix: 2, prefix: .standard, leadingZeros: false, groupCount: nil)
    }

    static var octal: Self {
        Self(radix: 8, prefix: .standard, leadingZeros: false, groupCount: nil)
    }
}

public extension FormatStyle where Self == RadixedIntegerFormatStyle<UInt64> {
    static var hex: Self {
        Self(radix: 16, prefix: .standard, leadingZeros: false, groupCount: nil, uppercase: true)
    }

    static var binary: Self {
        Self(radix: 2, prefix: .standard, leadingZeros: false, groupCount: nil)
    }

    static var octal: Self {
        Self(radix: 8, prefix: .standard, leadingZeros: false, groupCount: nil)
    }
}

// MARK: -

public extension BinaryInteger {
    @available(*, deprecated, message: "Use .formatted()")
    func formatted(radix: Int, prefix: RadixedIntegerFormatStyle<Self>.Prefix = .none, leadingZeros: Bool = false, groupCount: Int? = nil, groupSeparator: String = "_", uppercase: Bool = false) -> String {
        let formatter = RadixedIntegerFormatStyle(radix: radix, prefix: prefix, leadingZeros: leadingZeros, groupCount: groupCount, groupSeparator: groupSeparator, uppercase: uppercase)
        return formatter.format(self)
    }

    @available(*, deprecated, message: "Use .formatted(.hex)")
    var hexString: String {
        formatted(radix: 16, prefix: .standard, leadingZeros: true, groupCount: nil, groupSeparator: "_", uppercase: true)
    }
}

// MARK: -

public struct HexdumpFormatStyle<FormatInput>: FormatStyle where FormatInput: DataProtocol, FormatInput.Index == Int {
    public typealias FormatInput = FormatInput
    public typealias FormatOutput = String

    public func format(_ value: FormatInput) -> String {
        var s = ""
        Everything.hexdump(value, stream: &s)
        return s
    }
}

public extension FormatStyle where Self == HexdumpFormatStyle<Data> {
    static var hexdump: Self {
        HexdumpFormatStyle()
    }
}

public extension FormatStyle where Self == HexdumpFormatStyle<[UInt8]> {
    static var hexdump: Self {
        HexdumpFormatStyle()
    }
}

// Now do this for all DataProtocol types

// TODO: Remove Buffer.index == Int restriction
// TODO: Can we use DataProtocol instead?
// swiftlint:disable:next line_length
public func hexdump<Buffer>(_ buffer: Buffer, width: Int = 16, baseAddress: Int = 0, separator: String = "\n", terminator: String = "", stream: inout some TextOutputStream) where Buffer: RandomAccessCollection, Buffer.Element == UInt8, Buffer.Index == Int {
    for index in stride(from: 0, through: buffer.count, by: width) {
        let address = UInt(baseAddress + index).formatted(radix: 16, leadingZeros: true)
        let chunk = buffer[index ..< (index + min(width, buffer.count - index))]
        if chunk.isEmpty {
            break
        }
        let hex = chunk.map {
            $0.formatted(.hex.leadingZeros())
        }
        .joined(separator: " ")
        let paddedHex = hex.padding(toLength: width * 3 - 1, withPad: " ", startingAt: 0)

        let string = chunk.map { (c: UInt8) -> String in
            let scalar = UnicodeScalar(c)

            let character = Character(scalar)
            if isprint(Int32(c)) != 0 {
                return String(character)
            }
            else {
                return "?"
            }
        }
        .joined()

        stream.write("\(address)  \(paddedHex)  \(string)")
        stream.write(separator)
    }
    stream.write(terminator)
}

public func hexdump<Buffer>(_ buffer: Buffer, width: Int = 16, baseAddress: Int = 0) where Buffer: RandomAccessCollection, Buffer.Element == UInt8, Buffer.Index == Int {
    var string = String()
    hexdump(buffer, width: width, baseAddress: baseAddress, stream: &string)
    print(string)
}
