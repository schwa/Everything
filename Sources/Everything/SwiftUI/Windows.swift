#if os(macOS)
    import AppKit
    import Combine
    import Foundation
    import SwiftUI

    // TODO: Tie a window isVisible to a Binding so we can hide show as needed

    public class WindowsManager: NSResponder {
        public static let shared = WindowsManager()

        var cancellables: Set<AnyCancellable> = []
        public var windows: [NSWindow] = []
        var nextWindowIndex: Int = 0

        override public init() {
            super.init()

            NSApplication.shared.nextResponder = self

            let windowsMenu = NSApplication.shared.windowsMenu!
            let placeholderItem = windowsMenu.items.first { $0.identifier?.rawValue == "<placeholder>" }!
            nextWindowIndex = windowsMenu.index(of: placeholderItem)
            windowsMenu.removeItem(placeholderItem)
        }

        @available(*, unavailable)
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @discardableResult
        public func addPersistentWindow<Content>(title: String, _ content: () -> Content) -> NSWindow where Content: View {
            let viewController = NSHostingController(rootView: content())
            let window = NSWindow(contentViewController: viewController)
            windows.append(window)
            window.title = title
            window.isExcludedFromWindowsMenu = true

            let windowsMenu = NSApplication.shared.windowsMenu!

            let char = String((UnicodeScalar("0") + UInt32(windows.count - 1))!)
            let menuItem = NSMenuItem(title: "Show \(window.title) Window", action: #selector(showHideWindow(_:)), keyEquivalent: "")
            menuItem.representedObject = window
            menuItem.keyEquivalent = char
            menuItem.keyEquivalentModifierMask = [.command, .shift]

            windowsMenu.insertItem(menuItem, at: nextWindowIndex)
            nextWindowIndex += 1

            window.publisher(for: \.isVisible)
            .sink { _ in
                if window.isVisible {
                    menuItem.title = "Hide \(window.title) Window"
                }
                else {
                    menuItem.title = "Show \(window.title) Window"
                }
            }
            .store(in: &cancellables)
            return window
        }

        @IBAction
        // swiftlint:disable:next prohibited_interface_builder
        private func showHideWindow(_ sender: Any) {
            guard let menuItem = sender as? NSMenuItem else {
                return
            }
            let window = menuItem.representedObject as! NSWindow
            if window.isVisible {
                window.close()
            }
            else {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }

    public extension UnicodeScalar {
        static func + (lhs: UnicodeScalar, rhs: UInt32) -> UnicodeScalar? {
            UnicodeScalar(lhs.value + rhs)
        }
    }
#endif
