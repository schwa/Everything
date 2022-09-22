// swiftlint:disable indentation_width

import SwiftUI

public struct SmartField<Root>: View {
    let title: String
    let root: Root
    let keyPath: AnyKeyPath

    public init<Value>(title: String, root: Root, keyPath: ReferenceWritableKeyPath<Root, Value>) {
        self.title = title
        self.root = root
        self.keyPath = keyPath
    }

    public var body: some View {
        let value = root[keyPath: keyPath]
        switch value {
        case _ as Bool:
            let keyPath = self.keyPath as! ReferenceWritableKeyPath<Root, Bool>
            let binding = Binding(root: root, keyPath: keyPath)
            return Toggle(isOn: binding, label: { Text(title) }).eraseToAnyView()
        case _ as Float:
            let keyPath = self.keyPath as! ReferenceWritableKeyPath<Root, Float>
            let binding = Binding(root: root, keyPath: keyPath)
            let fieldEditor = SmartFieldEditorLibrary.defaultEditors()["float"]!
            return fieldEditor(title, AnyBinding(binding)).eraseToAnyView()
        case _ as CGFloat:
            let keyPath = self.keyPath as! ReferenceWritableKeyPath<Root, CGFloat>
            let binding = Binding(root: root, keyPath: keyPath)
            let fieldEditor = SmartFieldEditorLibrary.defaultEditors()["cgfloat"]!
            return fieldEditor(title, AnyBinding(binding)).eraseToAnyView()
//        case _ as SIMD3<Float>:
//            let keyPath = self.keyPath as! ReferenceWritableKeyPath<Root, SIMD3<Float>>
//            let binding = Binding(root: root, keyPath: keyPath)
//            let binding2 = Binding(other: binding, converter: colorConverter)
//            return ColorPicker(title, selection: binding2).eraseToAnyView()
        default:
            return Text("No SmartField for \(String(describing: type(of: value)))").eraseToAnyView()
        }
    }
}

public class SmartFieldEditorLibrary {
    public static let shared = SmartFieldEditorLibrary()

    var editors: [String: (String, AnyBinding) -> AnyView] = [:]

    public static func defaultEditors() -> [String: (String, AnyBinding) -> AnyView] {
        [
            "toggle": { ToggleFieldEditor(title: $0, binding: $1.binding(value: Bool.self)).eraseToAnyView() },
            "float": { FloatFieldEditor(title: $0, binding: $1.binding(value: Float.self)).eraseToAnyView() },
            "cgfloat": { FloatFieldEditor(title: $0, binding: $1.binding(value: CGFloat.self)).eraseToAnyView() },
        ]
    }
}

public struct AnyBinding {
    var base: Any

    public init<Value>(_ base: Binding<Value>) {
        self.base = base
    }

    public func binding<Value>(value: Value.Type) -> Binding<Value> {
        base as! Binding<Value>
    }
}

public protocol FieldEditor: View {
    associatedtype Value
    init(title: String, binding: Binding<Value>)
}

// MARK: -

public struct ToggleFieldEditor: View, FieldEditor {
    let title: String
    let binding: Binding<Bool>

    public init(title: String, binding: Binding<Bool>) {
        self.title = title
        self.binding = binding
    }

    public var body: some View {
        Toggle(isOn: binding) { Text(title) }
    }
}

public struct FloatFieldEditor<T>: View, FieldEditor where T: BinaryFloatingPoint {
    let title: String
    let binding: Binding<T>

    public init(title: String, binding: Binding<T>) {
        self.title = title
        self.binding = binding
    }

    public var body: some View {
        TextField(title, value: binding, formatter: NumberFormatter()).frame(maxWidth: 100)
    }
}

// #if os(macOS)
//    struct ColorFieldEditor: View, FieldEditor {
//        let title: String
//        let binding: Binding<NSColor>
//
//        var body: some View {
//            return HStack {
//                Text(title)
//                SwatchView(binding)
//            }
//        }
//    }
// #endif

// MARK: -

public struct ValueConverter<From, To> {
    public let forwards: (From) throws -> To
    public let backwards: ((To) throws -> From)?
}

public extension Binding {
    init<Other>(other: Binding<Other>, converter: ValueConverter<Other, Value>) {
        self = Binding<Value>(get: { () -> Value in
            let other = other.wrappedValue
            return forceTry {
                try converter.forwards(other)
            }
        }, set: { (value: Value) -> Void in
            forceTry {
                other.wrappedValue = try converter.backwards!(value)
            }
        })
    }
}

// MARK: -

public extension Binding {
    init<Root>(root: Root, keyPath: ReferenceWritableKeyPath<Root, Value>) {
        self = Binding(get: {
            root[keyPath: keyPath]
        }, set: {
            root[keyPath: keyPath] = $0
        })
    }
}
