// swiftlint:disable file_length

import Combine
import SwiftUI
import Geometry

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

#if !os(tvOS)
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

@available(macOS 13.0, iOS 16.0, *)
public struct RedlineModifier: ViewModifier {
    init() {
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    Canvas { context, size in
                        let r = CGRect(origin: .zero, size: size)
                        let lines: [(CGPoint, CGPoint)] = [
                            (r.minXMidY, r.maxXMidY),
                            (r.minXMidY + [0, -r.height * 0.25], r.minXMidY + [0, r.height * 0.25]),
                            (r.maxXMidY + [0, -r.height * 0.25], r.maxXMidY + [0, r.height * 0.25]),

                            (r.midXMinY, r.midXMaxY),
                            (r.midXMinY + [-r.width * 0.25, 0], r.midXMinY + [r.width * 0.25, 0]),
                            (r.midXMaxY + [-r.width * 0.25, 0], r.midXMaxY + [r.width * 0.25, 0]),
                        ]

                        context.stroke(Path(lines: lines), with: .color(.white.opacity(0.5)), lineWidth: 3)
                        context.stroke(Path(lines: lines), with: .color(.red), lineWidth: 1)
                        if let symbol = context.resolveSymbol(id: "width") {
                            context.draw(symbol, at: (r.midXMidY + r.minXMidY) / 2, anchor: .center)
                        }
                        if let symbol = context.resolveSymbol(id: "height") {
                            context.draw(symbol, at: (r.midXMidY + r.midXMinY) / 2, anchor: .center)
                        }
                    }
                symbols: {
                    Text(verbatim: proxy.size.width.formatted())
                        .padding(1)
                        .background(.thickMaterial)
                        .tag("width")
                    Text(verbatim: proxy.size.height.formatted())
                        .padding(1)
                        .background(.thickMaterial)
                        .tag("height")
                    }
                }
            }
    }
}

@available(macOS 13.0, iOS 16.0, *)
public extension View {
    @ViewBuilder
    func redlined(_ enabled: Bool = true) -> some View {
        if enabled {
            modifier(RedlineModifier())
        }
        else {
            self
        }
    }
}

@available(macOS 13.0, iOS 16.0, *)
public struct WorkInProgressView: View {
    let colors: (Color, Color)

    public init(colors: (Color, Color) = (.black, .yellow)) {
        self.colors = colors
    }

    public var body: some View {
        let tileSize = CGSize(16, 16)
        // swiftlint:disable:next accessibility_label_for_image
        let tile = Image(size: tileSize) { context in
            context.fill(Path(tileSize), with: .color(colors.0))
            context.fill(Path(vertices: [[0.0, 0.0], [0.0, 0.5], [0.5, 0]].map { $0 * CGPoint(tileSize) }), with: .color(colors.1))
            context.fill(Path(vertices: [[0.0, 1], [1.0, 0.0], [1, 0.5], [0.5, 1]].map { $0 * CGPoint(tileSize) }), with: .color(colors.1))
        }
        Canvas { context, size in
            context.fill(Path(size), with: .tiledImage(tile, sourceRect: CGRect(size: tileSize)))
        }
    }
}

@available(macOS 13.0, iOS 16.0, *)
internal struct DebuggingInfoModifier: ViewModifier {
    @AppStorage("showDebuggingInfo")
    var showDebuggingInfo = false

    func body(content: Content) -> some View {
        if showDebuggingInfo {
            content
                .font(.caption.monospaced())
#if !os(tvOS)
                .textSelection(.enabled)
#endif
                .padding(4)
                .background {
                    WorkInProgressView()
                        .opacity(0.1)
                }
        }
    }
}

@available(macOS 13.0, iOS 16.0, *)
public extension View {
    func debuggingInfo() -> some View {
        modifier(DebuggingInfoModifier())
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
