#if os(macOS)
    import Combine
    import SwiftUI

    public struct KeyboardPublisherEnvironmentKey: EnvironmentKey {
        public static var defaultValue: AnyPublisher<NSEvent, Never> = Empty<NSEvent, Never>().eraseToAnyPublisher()
    }

    public extension EnvironmentValues {
        var keyboardPublisher: AnyPublisher<NSEvent, Never> {
            get {
                self[KeyboardPublisherEnvironmentKey.self]
            }
            set {
                self[KeyboardPublisherEnvironmentKey.self] = newValue
            }
        }
    }

    public extension View {
        func onKeyboardEvent(_ handler: @escaping (NSEvent) -> Void) -> some View {
            OnKeyboardEventView(handler: handler, content: self)
        }
    }

    // TODO: Why dis the handler approach not work?
    // struct OnKeyboardEventModifier: ViewModifier {
//
//    let handler: (NSEvent) -> Void
//
//    func body(content: Content) -> some View {
//        return OnKeyboardEventView(handler: handler, content: content)
//    }
    // }

    public struct OnKeyboardEventView<Content>: View where Content: View {
        public let handler: (NSEvent) -> Void
        public let content: Content

        @Environment(\.keyboardPublisher)
        public var keyboardPublisher: AnyPublisher<NSEvent, Never>

        public var body: some View {
            content.onReceive(self.keyboardPublisher) { event in
                self.handler(event)
            }
        }
    }
#endif
