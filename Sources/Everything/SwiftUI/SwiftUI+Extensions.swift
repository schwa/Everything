// swiftlint:disable file_length

import Combine
import SwiftUI
#if os(macOS)
    import AppKit
#endif

public struct PlaceholderShape: Shape {
    public init() {
    }

    public func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addRect(rect)
        }
    }
}

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
        return Text(content).lineLimit(0)
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

public extension Path {
    mutating func addLine(from: CGPoint, to: CGPoint) {
        move(to: from)
        addLine(to: to)
    }

    mutating func addSCurve(from start: CGPoint, to end: CGPoint) {
        let mid = (end + start) * 0.5

        let c1 = CGPoint(mid.x, start.y)
        let c2 = CGPoint(mid.x, end.y)

        move(to: start)
        addQuadCurve(to: mid, control: c1)
        addQuadCurve(to: end, control: c2)
    }
}

public extension Path {
    init(lines: [(CGPoint, CGPoint)]) {
        self = Path()
        lines.forEach {
            move(to: $0.0)
            addLine(to: $0.1)
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

public extension Path {
    var elements: [Element] {
        var elements: [Element] = []
        forEach { elements.append($0) }
        return elements
    }

    init(elements: [Element]) {
        self = Path { path in
            elements.forEach { element in
                switch element {
                case .move(let point):
                    path.move(to: point)
                case .line(let point):
                    path.addLine(to: point)
                case .quadCurve(let to, let control):
                    path.addQuadCurve(to: to, control: control)
                case .curve(let to, let control1, let control2):
                    path.addCurve(to: to, control1: control1, control2: control2)
                case .closeSubpath:
                    path.closeSubpath()
                }
            }
        }
    }
}

public extension Array where Element == Path.Element {
    func path() -> Path {
        Path(elements: self)
    }
}

public extension Path {
    struct Corners: OptionSet {
        public let rawValue: UInt8

        public static let topLeft = Corners(rawValue: 0b0001)
        public static let topRight = Corners(rawValue: 0b0010)
        public static let bottomLeft = Corners(rawValue: 0b0100)
        public static let bottomRight = Corners(rawValue: 0b1000)

        public static let all: Corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    init(roundedRect rect: CGRect, cornerRadius: CGFloat, style: RoundedCornerStyle = .circular, corners: Corners) {
        let elements = Path(roundedRect: rect, cornerRadius: cornerRadius, style: style).elements

        assert(elements.count == 10)

        self = Path(elements: elements
            .enumerated()
            // swiftlint:disable:next closure_body_length
            .map { index, element in
                let corner: Corners
                switch (index, element) {
                case (2, .curve):
                    corner = .bottomRight
                case (4, .curve):
                    corner = .bottomLeft
                case (6, .curve):
                    corner = .topLeft
                case (8, .curve):
                    corner = .topRight
                default:
                    return element
                }
                if !corners.contains(corner) {
                    switch corner {
                    case .topLeft:
                        return .line(to: rect.minXMinY)
                    case .topRight:
                        return .line(to: rect.maxXMinY)
                    case .bottomLeft:
                        return .line(to: rect.minXMaxY)
                    case .bottomRight:
                        return .line(to: rect.maxXMaxY)
                    default:
                        fatalError("Invalid corner.")
                    }
                }
                else {
                    return element
                }
            })
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

public struct Crosshair: Shape {
    public func path(in rect: CGRect) -> SwiftUI.Path {
        Path { path in
            path.move(to: rect.minXMidY)
            path.addLine(to: rect.maxXMidY)
            path.move(to: rect.midXMinY)
            path.addLine(to: rect.midXMaxY)
        }
    }
}

public extension SwiftUI.Path {
    mutating func addCrosshair(point: CGPoint, size: CGSize) {
        let size = CGPoint(size)
        move(to: point - size * [-0.5, 0])
        addLine(to: point - size * [0.5, 0])
        move(to: point - size * [0, -0.5])
        addLine(to: point - size * [0, 0.5])
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

// #if os(iOS)
//    public extension Button where Label == Image {
//        init(systemImage: SystemImage, action: @escaping () -> Void) {
//            self.init(action: action, label: { Image(systemName: systemImage.rawValue) })
//        }
//    }
//
//    public extension PopoverButton where Label == Image {
//        init(systemImage: SystemImage, content: @escaping () -> Content) {
//            self.init(label: { Image(systemName: systemImage.rawValue) }, content: content)
//        }
//    }
// #endif

// public extension Color {
//    init(_ color: SIMD4<Float>) {
//        let color = color.map { Double($0) }
//        self = Color(red: color[0], green: color[1], blue: color[2], opacity: color[3])
//    }
// }

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

