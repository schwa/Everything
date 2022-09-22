#if os(macOS)
    import AppKit
    import SwiftUI

    @available(*, deprecated, message: "Use TextEditor")
    public struct TextView: NSViewRepresentable {
        @Binding
        public var text: String

        public class Coordinator: NSObject, NSTextViewDelegate {
            var updateText: ((String) -> Void)?

            @objc
            public func textDidChange(_ notification: Notification) {
                updateText?((notification.object as! NSText).string)
            }
        }

        public func makeCoordinator() -> Coordinator {
            let coordinator = Coordinator()
            coordinator.updateText = {
                self.text = $0
            }
            return coordinator
        }

        public func makeNSView(context: NSViewRepresentableContext<TextView>) -> NSTextView {
            let textView = NSTextView()
            textView.delegate = context.coordinator
            return textView
        }

        public func updateNSView(_ nsView: NSTextView, context: NSViewRepresentableContext<TextView>) {
            nsView.string = text
        }
    }
#endif
