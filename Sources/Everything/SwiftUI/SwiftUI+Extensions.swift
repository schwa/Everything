// swiftlint:disable file_length

import Combine
import SwiftUI
#if os(macOS)
    import AppKit
#endif

// MARK: -

public struct DescriptionView<Value>: View {
    public enum Mode {
        case describing
        case dumping
    }

    let value: Value
    let mode: Mode

    public init(_ value: Value, mode: Mode = .describing) {
        self.value = value
        self.mode = mode
    }

    public var body: some View {
        var content: String
        switch mode {
        case .describing:
            content = String(describing: value)
        case .dumping:
            content = ""
            dump(value, to: &content)
        }
        return Text(content)
    }
}

public struct SubscribedDescriptionView<P>: View where P: Publisher, P.Failure == Never {
    let publisher: P
    @State var value: P.Output?

    public init(publisher: P) {
        self.publisher = publisher
    }

    public var body: some View {
        DescriptionView(value).onReceive(publisher) { value in
            self.value = value
        }
    }
}

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

#if os(macOS)
    @available(*, deprecated, message: "Use .monospaced()")
    public extension Font {
        static func code(ofSize size: CGFloat = 12, weight: NSFont.Weight = .medium) -> Font {
            Font(NSFont.monospacedSystemFont(ofSize: size, weight: weight) as CTFont)
        }
    }

#elseif os(iOS)
    @available(*, deprecated, message: "Use .monospaced()")
    public extension Font {
        static func code(ofSize hexSize: CGFloat = 12, weight: UIFont.Weight = .medium) -> Font {
            Font(UIFont.monospacedSystemFont(ofSize: hexSize, weight: weight) as CTFont)
        }
    }
#endif

// public struct TitledView<Content>: View where Content: View {
//    public let title: String
//    public let content: () -> Content
//
//    public init(title: String, content: @escaping () -> Content) {
//        self.title = title
//        self.content = content
//    }
//
//    public var body: some View {
//        content()
//    }
// }
//
// public extension View {
//    func titled(_ title: String) -> TitledView<Self> {
//        return TitledView(title: title) {
//            self
//        }
//    }
// }

#if os(macOS)
    public struct ViewControllerView<VC>: NSViewControllerRepresentable where VC: NSViewController {
        let viewController: VC

        public init(viewController: VC) {
            self.viewController = viewController
        }

        public func makeNSViewController(context: NSViewControllerRepresentableContext<ViewControllerView>) -> VC {
            viewController
        }

        public func updateNSViewController(_ nsViewController: VC, context: NSViewControllerRepresentableContext<ViewControllerView>) {
        }
    }
#endif // os(macOS)

public extension Binding {
    func unwrappingRebound<T>() -> Binding<T> where Value == T? {
        Binding<T>(get: {
            self.wrappedValue!
        }, set: {
            self.wrappedValue = $0
        })
    }

    func unwrappingRebound<T>(default: @escaping () -> T) -> Binding<T> where Value == T? {
        Binding<T>(get: {
            self.wrappedValue ?? `default`()
        }, set: {
            self.wrappedValue = $0
        })
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

    public init(value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(wrappedValue: value)
        self.content = content
    }

    public var body: some View {
        content($value)
    }
}


public extension Button {
    init(title: String, systemImage: String, action: @escaping () -> Void) where Label == SwiftUI.Label<Text, Image> {
        self = Button(action: action) {
            Label(title, systemImage: systemImage)
        }
    }
}

public extension Button {
    init(systemImage systemName: String, action: @escaping () -> Void) where Label == Image {
        self = Button(action: action) {
            Image(systemName: systemName)
        }
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

// TODO: Make generic
public struct RoundedPanel<Content>: View where Content: View {
    let content: () -> Content

    public var body: some View {
        content()
            .frame(width: 320, height: 480)
            .cornerRadius(8)
            .padding()
    }
}

public extension Gesture {
    func eraseToAnyGesture() -> AnyGesture<Self.Value> {
        AnyGesture(self)
    }
}

public extension View {
    func gesture <G>(_ gesture: () -> G) -> some View where G: Gesture {
        self.gesture(gesture())
    }
}

public extension View {
    func offset(_ point: CGPoint) -> some View {
        offset(x: point.x, y: point.y)
    }
}

public struct PaneledModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white.cornerRadius(8))
            .padding()
    }
}

public extension View {
    func paneled() -> some View {
        modifier(PaneledModifier())
    }
}

