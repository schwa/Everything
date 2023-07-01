// swiftlint:disable file_length

import Combine
import SwiftUI
#if os(macOS)
    import AppKit
#endif

// MARK: -

@available(*, deprecated, message: "Stop using.")
public struct PublishedContentView<Content, P>: View where Content: View, P: Publisher, P.Failure == Never {
    let publisher: P
    let animated: Bool
    let content: (P.Output) -> Content

    @State var value: P.Output?

    public init(publisher: P, animated: Bool = false, content: @escaping (P.Output) -> Content) {
        self.publisher = publisher
        self.animated = animated
        self.content = content
    }

    public var body: some View {
        ZStack {
            value.map { content($0) }
        }
        .onReceive(publisher) { value in
            if self.animated {
                withAnimation {
                    self.value = value
                }
            }
            else {
                self.value = value
            }
        }
    }
}

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
    var value: Value
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

// TODO: Use LazyView
public struct DeferredView<Content>: View where Content: View {
    var content: () -> Content

    @State
    private var appeared = false

    public var body: some View {
        Group {
            EmptyView()
            appeared ? content() : nil
        }
        .onAppear {
            self.appeared = true
        }
        .onDisappear {
            self.appeared = false
        }
    }
}

public struct PopoverButton<Label, Content>: View where Label: View, Content: View {
    let label: () -> Label
    let content: () -> Content

    @State
    var visible = false

    public init(label: @escaping () -> Label, content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }

    public var body: some View {
        Button(action: { self.visible.toggle() }, label: label)
            .popover(isPresented: $visible, content: content)
    }
}

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
