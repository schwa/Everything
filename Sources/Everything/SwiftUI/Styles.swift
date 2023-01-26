// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 34)

import SwiftUI

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `ButtonStyle`.
///
/// Allows creation of type-erased `ButtonStyle` using a closure to create the style's body.
@available(macOS 10.15, iOS 13.0, *)
public struct AnyButtonStyle <Body>: ButtonStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 10.15, iOS 13.0, *)
public extension View {
    /// Modify the `buttonStyle` style via a closure.
    func buttonStyle<B>(_ body: @escaping (AnyButtonStyle<B>.Configuration) -> B) -> some View where B: View {
        buttonStyle(AnyButtonStyle(body))
    }
}

// MARK: -

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `ControlGroupStyle`.
///
/// Allows creation of type-erased `ControlGroupStyle` using a closure to create the style's body.
@available(macOS 10.15, iOS 13.0, *)
public struct AnyControlGroupStyle <Body>: ControlGroupStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 10.15, iOS 13.0, *)
public extension View {
    /// Modify the `controlGroupStyle` style via a closure.
    func controlGroupStyle<B>(_ body: @escaping (AnyControlGroupStyle<B>.Configuration) -> B) -> some View where B: View {
        controlGroupStyle(AnyControlGroupStyle(body))
    }
}

// MARK: -

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `DatePickerStyle`.
///
/// Allows creation of type-erased `DatePickerStyle` using a closure to create the style's body.
@available(macOS 13, iOS 16.0, *)
public struct AnyDatePickerStyle <Body>: DatePickerStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 13, iOS 16.0, *)
public extension View {
    /// Modify the `datePickerStyle` style via a closure.
    func datePickerStyle<B>(_ body: @escaping (AnyDatePickerStyle<B>.Configuration) -> B) -> some View where B: View {
        datePickerStyle(AnyDatePickerStyle(body))
    }
}

// MARK: -

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `DisclosureGroupStyle`.
///
/// Allows creation of type-erased `DisclosureGroupStyle` using a closure to create the style's body.
@available(macOS 13, iOS 16.0, *)
public struct AnyDisclosureGroupStyle <Body>: DisclosureGroupStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 13, iOS 16.0, *)
public extension View {
    /// Modify the `disclosureGroupStyle` style via a closure.
    func disclosureGroupStyle<B>(_ body: @escaping (AnyDisclosureGroupStyle<B>.Configuration) -> B) -> some View where B: View {
        disclosureGroupStyle(AnyDisclosureGroupStyle(body))
    }
}

// MARK: -

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `FormStyle`.
///
/// Allows creation of type-erased `FormStyle` using a closure to create the style's body.
@available(macOS 13, iOS 16.0, *)
public struct AnyFormStyle <Body>: FormStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 13, iOS 16.0, *)
public extension View {
    /// Modify the `formStyle` style via a closure.
    func formStyle<B>(_ body: @escaping (AnyFormStyle<B>.Configuration) -> B) -> some View where B: View {
        formStyle(AnyFormStyle(body))
    }
}

// MARK: -

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `GaugeStyle`.
///
/// Allows creation of type-erased `GaugeStyle` using a closure to create the style's body.
@available(macOS 13, iOS 16.0, *)
public struct AnyGaugeStyle <Body>: GaugeStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 13, iOS 16.0, *)
public extension View {
    /// Modify the `gaugeStyle` style via a closure.
    func gaugeStyle<B>(_ body: @escaping (AnyGaugeStyle<B>.Configuration) -> B) -> some View where B: View {
        gaugeStyle(AnyGaugeStyle(body))
    }
}

// MARK: -

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `GroupBoxStyle`.
///
/// Allows creation of type-erased `GroupBoxStyle` using a closure to create the style's body.
@available(macOS 10.15, iOS 13.0, *)
public struct AnyGroupBoxStyle <Body>: GroupBoxStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 10.15, iOS 13.0, *)
public extension View {
    /// Modify the `groupBoxStyle` style via a closure.
    func groupBoxStyle<B>(_ body: @escaping (AnyGroupBoxStyle<B>.Configuration) -> B) -> some View where B: View {
        groupBoxStyle(AnyGroupBoxStyle(body))
    }
}

// MARK: -

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `LabelStyle`.
///
/// Allows creation of type-erased `LabelStyle` using a closure to create the style's body.
@available(macOS 10.15, iOS 13.0, *)
public struct AnyLabelStyle <Body>: LabelStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 10.15, iOS 13.0, *)
public extension View {
    /// Modify the `labelStyle` style via a closure.
    func labelStyle<B>(_ body: @escaping (AnyLabelStyle<B>.Configuration) -> B) -> some View where B: View {
        labelStyle(AnyLabelStyle(body))
    }
}

// MARK: -

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `LabeledContentStyle`.
///
/// Allows creation of type-erased `LabeledContentStyle` using a closure to create the style's body.
@available(macOS 13, iOS 16.0, *)
public struct AnyLabeledContentStyle <Body>: LabeledContentStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 13, iOS 16.0, *)
public extension View {
    /// Modify the `labeledContentStyle` style via a closure.
    func labeledContentStyle<B>(_ body: @escaping (AnyLabeledContentStyle<B>.Configuration) -> B) -> some View where B: View {
        labeledContentStyle(AnyLabeledContentStyle(body))
    }
}

// MARK: -

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `MenuStyle`.
///
/// Allows creation of type-erased `MenuStyle` using a closure to create the style's body.
@available(macOS 10.15, iOS 13.0, *)
public struct AnyMenuStyle <Body>: MenuStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 10.15, iOS 13.0, *)
public extension View {
    /// Modify the `menuStyle` style via a closure.
    func menuStyle<B>(_ body: @escaping (AnyMenuStyle<B>.Configuration) -> B) -> some View where B: View {
        menuStyle(AnyMenuStyle(body))
    }
}

// MARK: -

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `NavigationSplitViewStyle`.
///
/// Allows creation of type-erased `NavigationSplitViewStyle` using a closure to create the style's body.
@available(macOS 13, iOS 16.0, *)
public struct AnyNavigationSplitViewStyle <Body>: NavigationSplitViewStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 13, iOS 16.0, *)
public extension View {
    /// Modify the `navigationSplitViewStyle` style via a closure.
    func navigationSplitViewStyle<B>(_ body: @escaping (AnyNavigationSplitViewStyle<B>.Configuration) -> B) -> some View where B: View {
        navigationSplitViewStyle(AnyNavigationSplitViewStyle(body))
    }
}

// MARK: -

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `ProgressViewStyle`.
///
/// Allows creation of type-erased `ProgressViewStyle` using a closure to create the style's body.
@available(macOS 10.15, iOS 13.0, *)
public struct AnyProgressViewStyle <Body>: ProgressViewStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 10.15, iOS 13.0, *)
public extension View {
    /// Modify the `progressViewStyle` style via a closure.
    func progressViewStyle<B>(_ body: @escaping (AnyProgressViewStyle<B>.Configuration) -> B) -> some View where B: View {
        progressViewStyle(AnyProgressViewStyle(body))
    }
}

// MARK: -

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `TableStyle`.
///
/// Allows creation of type-erased `TableStyle` using a closure to create the style's body.
@available(macOS 12, iOS 16.0, *)
public struct AnyTableStyle <Body>: TableStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 12, iOS 16.0, *)
public extension View {
    /// Modify the `tableStyle` style via a closure.
    func tableStyle<B>(_ body: @escaping (AnyTableStyle<B>.Configuration) -> B) -> some View where B: View {
        tableStyle(AnyTableStyle(body))
    }
}

// MARK: -

// ###sourceLocation(file: "/Users/schwa/Shared/Projects/Everything/Sources/Everything/SwiftUI/Styles.swift.gyb", line: 38)

/// A type-erased `ToggleStyle`.
///
/// Allows creation of type-erased `ToggleStyle` using a closure to create the style's body.
@available(macOS 10.15, iOS 13.0, *)
public struct AnyToggleStyle <Body>: ToggleStyle where Body: View {
    let body: (Configuration) -> Body

    public init(_ body: @escaping (Configuration) -> Body) {
        self.body = body
    }

    public func makeBody(configuration: Configuration) -> some View {
        body(configuration)
    }
}

@available(macOS 10.15, iOS 13.0, *)
public extension View {
    /// Modify the `toggleStyle` style via a closure.
    func toggleStyle<B>(_ body: @escaping (AnyToggleStyle<B>.Configuration) -> B) -> some View where B: View {
        toggleStyle(AnyToggleStyle(body))
    }
}

// MARK: -

