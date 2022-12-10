import Foundation
import SwiftUI

public extension Array {
    func extended(with element: Element, count: Int) -> Self {
        self + repeatElement(element, count: count - self.count)
    }

    func extended(with element: Element?, count: Int) -> [Element?] {
        self + repeatElement(element, count: count - self.count)
    }
}

public func inverseLerp(from lowerBound: Float, to upperBound: Float, by value: Float) -> Float {
    (value - lowerBound) / (upperBound - lowerBound)
}

extension CharacterSet: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = CharacterSet(charactersIn: value)
    }
}

public extension CharacterSet {
    static func + (lhs: CharacterSet, rhs: CharacterSet) -> CharacterSet {
        lhs.union(rhs)
    }
}

public extension Character {
    static func random(in set: String) -> Character {
        set.randomElement()!
    }
}

// MARK: -

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(string: value)!
    }
}

extension URL: ExpressibleByStringInterpolation {
}

public extension Optional where Wrapped: Collection {
    func nilify() -> Wrapped? {
        switch self {
        case .some(let value):
            if value.isEmpty {
                return nil
            }
            else {
                return value
            }
        case .none:
            return nil
        }
    }
}

public extension Image {
    init(data: Data) throws {
        #if os(macOS)
            guard let nsImage = NSImage(data: data) else {
                throw GeneralError.generic("Could not load image")
            }
            self = Image(nsImage: nsImage)
        #else
            guard let uiImage = UIImage(data: data) else {
                throw GeneralError.generic("Could not load image")
            }
            self = Image(uiImage: uiImage)
        #endif
    }
}

public extension Image {
    init(url: URL) throws {
        #if os(macOS)
            guard let nsImage = NSImage(contentsOf: url) else {
                throw GeneralError.generic("Could not load image")
            }
            self = Image(nsImage: nsImage)
        #else
            guard let uiImage = UIImage(contentsOfFile: url.path) else {
                throw GeneralError.generic("Could not load image")
            }
            self = Image(uiImage: uiImage)
        #endif
    }
}

public struct WeakBox<Content> where Content: AnyObject {
    public weak var content: Content?

    public init(_ content: Content) {
        self.content = content
    }
}

public struct TypeID: Hashable {
    public let rawValue: String

    public init(_ type: (some Any).Type) {
        rawValue = String(describing: type)
    }
}

extension TypeID: Codable {
}

// MARK: -

public struct CompositeHash<Element>: Hashable where Element: Hashable {
    let elements: [Element]

    public init(_ elements: [Element]) {
        self.elements = elements
    }
}

extension CompositeHash: Sendable where Element: Sendable {
}

extension CompositeHash: Codable where Element: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        elements = try container.decode([Element].self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(elements)
    }
}

extension CompositeHash: Comparable where Element: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        let max = max(lhs.elements.count, rhs.elements.count)
        let lhs = lhs.elements.extended(count: max)
        let rhs = rhs.elements.extended(count: max)
        for (lhs, rhs) in zip(lhs, rhs) {
            switch (lhs, rhs) {
            case (.none, .none):
                fatalError("Should be impossible to be get here.")
            case (.some, .none):
                return false
            case (.none, .some):
                return true
            case (.some(let lhs), .some(let rhs)):
                if lhs < rhs {
                    return true
                }
                else if lhs > rhs {
                    return false
                }
                else {
                    continue
                }
            }
        }
        return false
    }
}

// MARK: -

public extension Collection {
    func extended(count: Int) -> [Element?] {
        let extra = count - self.count
        return map { Optional($0) } + repeatElement(nil, count: extra)
    }
}

// MARK: -

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
                        Text(verbatim: "\(proxy.size.width, format: .number)")
                            .padding(1)
                            .background(.thickMaterial)
                            .tag("width")
                        Text(verbatim: "\(proxy.size.height, format: .number)")
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

public extension Button {
    init(title: String, systemImage systemName: String, action: @escaping @Sendable () async -> Void) where Label == SwiftUI.Label<Text, Image> {
        self = Button(action: {
            Task {
                await action()
            }
        }, label: {
            SwiftUI.Label(title, systemImage: systemName)
        })
    }

    init(_ title: String, action: @escaping @Sendable () async -> Void) where Label == Text {
        self = Button(title) {
            Task {
                await action()
            }
        }
    }

    init(systemImage systemName: String, action: @escaping @Sendable () async -> Void) where Label == Image {
        self = Button(action: {
            Task {
                await action()
            }
        }, label: {
            Image(systemName: systemName)
        })
    }

    init(action: @Sendable @escaping () async -> Void, @ViewBuilder label: () -> Label) {
        self = Button(action: {
            Task {
                await action()
            }
        }, label: {
            label()
        })
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

    public func body(content: Content) -> some View {
        if showDebuggingInfo {
            content
                .font(.caption.monospaced())
                .textSelection(.enabled)
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

public extension Path {
    init(_ rectSize: CGSize) {
        self = Path(CGRect(size: rectSize))
    }
}

public extension FSPath {
    #if os(macOS)
        func reveal() {
            NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
        }
    #endif
}

public struct DebugDescriptionView<Value>: View {
    let value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public var body: some View {
        Group {
            if let value = value as? CustomDebugStringConvertible {
                Text(verbatim: "\(value.debugDescription)")
            }
            else if let value = value as? CustomStringConvertible {
                Text(verbatim: "\(value.description)")
            }
            else {
                Text(verbatim: "\(String(describing: value))")
            }
        }
        .textSelection(.enabled)
        .font(.body.monospaced())
    }
}

