import Foundation

public extension String {
    init<F>(_ input: F.FormatInput, format: F) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
        self = format.format(input)
    }
}

public extension String {
    init <Value, Style>(_ value: Value, format: Style) where Style: FormatStyle, Style.FormatOutput == String, Style.FormatInput == Value {
        self = format.format(value)
    }
}

public extension String.StringInterpolation {
    mutating func appendInterpolation <Value, Style>(_ value: Value, format: Style) where Style: FormatStyle, Style.FormatOutput == String, Style.FormatInput == Value {
        appendInterpolation(format.format(value))
    }
}

// MARK: -

public struct DescribedFormatStyle <FormatInput>: FormatStyle {
    public typealias FormatInput = FormatInput
    public typealias FormatOutput = String

    public func format(_ value: FormatInput) -> String {
        return String(describing: value)
    }
}

public extension FormatStyle where Self == DescribedFormatStyle<Any> {
    static var described: DescribedFormatStyle <FormatInput> {
        return DescribedFormatStyle()
    }
}

// MARK: -

public struct DumpedFormatStyle <FormatInput>: FormatStyle {
    public typealias FormatInput = FormatInput
    public typealias FormatOutput = String

    public func format(_ value: FormatInput) -> String {
        var s = ""
        dump(value, to: &s)
        return s
    }
}

public extension FormatStyle where Self == DescribedFormatStyle<Any> {
    static var dumped: DumpedFormatStyle <FormatInput> {
        return DumpedFormatStyle()
    }
}
