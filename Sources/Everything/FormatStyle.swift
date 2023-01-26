import Foundation

public extension String {
    init<F>(_ input: F.FormatInput, format: F) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
        self = format.format(input)
    }
}

public extension String {
    init<Value, Style>(_ value: Value, format: Style) where Style: FormatStyle, Style.FormatOutput == String, Style.FormatInput == Value {
        self = format.format(value)
    }
}

public extension String.StringInterpolation {
    mutating func appendInterpolation<Value, Style>(_ value: Value, format: Style) where Style: FormatStyle, Style.FormatOutput == String, Style.FormatInput == Value {
        appendInterpolation(format.format(value))
    }
}

// MARK: -

public struct DescribedFormatStyle<FormatInput>: FormatStyle {
    public typealias FormatInput = FormatInput
    public typealias FormatOutput = String

    public func format(_ value: FormatInput) -> String {
        String(describing: value)
    }
}

public extension FormatStyle where Self == DescribedFormatStyle<Any> {
    static var described: DescribedFormatStyle<FormatInput> {
        DescribedFormatStyle()
    }
}

// MARK: -

public struct DumpedFormatStyle<FormatInput>: FormatStyle {
    public typealias FormatInput = FormatInput
    public typealias FormatOutput = String

    public func format(_ value: FormatInput) -> String {
        var s = ""
        dump(value, to: &s)
        return s
    }
}

public extension FormatStyle where Self == DescribedFormatStyle<Any> {
    static var dumped: DumpedFormatStyle<FormatInput> {
        DumpedFormatStyle()
    }
}

// MARK: -

public protocol CompositeFormatStyle: FormatStyle {
    associatedtype ComponentStyle: FormatStyle
    var componentStyle: ComponentStyle { get set }
}

public extension CompositeFormatStyle {
    func component(_ style: ComponentStyle) -> Self {
        var copy = self
        copy.componentStyle = style
        return copy
    }
}

public struct CGPointStyle: CompositeFormatStyle {
    public var componentStyle: FloatingPointFormatStyle<Double>

    public init() {
        componentStyle = .number
    }

    public func format(_ value: CGPoint) -> String {
        "\(componentStyle.format(value.x)), \(componentStyle.format(value.y))"
    }
}

public extension FormatStyle where Self == CGPointStyle {
    static var point: CGPointStyle {
        CGPointStyle()
    }
}

