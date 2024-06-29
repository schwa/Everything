// swiftlint:disable file_length

import Combine
import SwiftUI

public extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

/**
 Tired of sprinkling those little one shot `isPresenting` style state properties through your code?

 ValueView(value: false) { value in
 Button("Mass Follow") {
 value.wrappedValue = true
 }
 .fileImporter(isPresented: value, allowedContentTypes: [.commaSeparatedText]) { result in

 }
 }
 */
public struct ValueView<Value, Content>: View where Content: View {
    @State
    private var value: Value
    let content: (Binding<Value>) -> Content

    public init(value: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(wrappedValue: value)
        self.content = content
    }

    public var body: some View {
        content($value)
    }
}

public struct LazyView<Content: View>: View {
    let content: () -> Content
    public init(_ content: @escaping () -> Content) {
        self.content = content
    }

    public var body: Content {
        content()
    }
}

#if !os(tvOS)
public struct PopoverButton<Label, Content>: View where Label: View, Content: View {
    let label: () -> Label
    let content: () -> Content

    @State
    private var visible = false

    public init(label: @escaping () -> Label, content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }

    public var body: some View {
        Button(action: { visible.toggle() }, label: label)
            .popover(isPresented: $visible, content: content)
    }
}
#endif

public extension Gesture {
    func eraseToAnyGesture() -> AnyGesture<Self.Value> {
        AnyGesture(self)
    }
}

public extension View {
    func gesture(_ gesture: () -> some Gesture) -> some View {
        self.gesture(gesture())
    }
}

public extension View {
    func offset(_ point: CGPoint) -> some View {
        offset(x: point.x, y: point.y)
    }
}

public extension Text {
    init(describing value: Any) {
        self = Text(verbatim: "\(value)")
    }
}

public extension Text {
    static func lorem() -> Self {
        // swiftlint:disable line_length
        Text("""
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        """)
        // swiftlint:enable line_length
    }
}
