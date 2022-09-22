/*
//
//  SwiftUI+Windows.swift
//  GraphicsDemos_OSX
//
//  Created by Jonathan Wight on 4/21/20.
//  Copyright © 2020 schwa.io. All rights reserved.
//

#if os(macOS)
    import AppKit
    import Combine
    import SwiftUI

    private var windowControllers: [AnyHashable: NSWindowController] = [:]
    private var cancellables: Set<AnyCancellable> = []

    @discardableResult
    @MainActor
    public func showWindow<Content>(title: String? = nil, id: AnyHashable? = nil, rootView: Content) -> NSWindowController where Content: View {
        if let key = id, let windowController = windowControllers[key] {
            windowController.window?.makeKeyAndOrderFront(nil)
            return windowController
        }

        // TODO: Add to window menu

        // WARNING: This is a bit of a hack, but does work.  out.
        let rootView = rootView.overlay(GeometryReader { geometry -> AnyView in
            assert(geometry.size.width > 0 && geometry.size.height > 0, "Don't forget to use .frame() with showWindow's rootView")
            // Type erasing an EmptyView seems to prevent it from getting optimised away.
            return EmptyView().eraseToAnyView()
        })

        let viewController = NSHostingController(rootView: rootView)
        let window = NSWindow(contentViewController: viewController)
        if let title {
            window.title = title
        }

        let windowController = NSWindowController(window: window)
        let key = id ?? AnyHashable(windowController)
        windowControllers[key] = windowController

        NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)
            .filter { ($0.object as? NSWindow) === window }
            .sink { _ in
                windowControllers[key] = nil
            }
            .store(in: &cancellables)

        window.makeKeyAndOrderFront(nil)
        return windowController
    }

    // @available(*, deprecated, message: "Deprecated")
    public struct WindowEnvironmentkey: EnvironmentKey {
        public static let defaultValue: (() -> NSWindow?) = { nil }
    }

    public extension EnvironmentValues {
        var window: () -> NSWindow? {
            get {
                self[WindowEnvironmentkey.self]
            }
            set {
                self[WindowEnvironmentkey.self] = newValue
            }
        }
    }

    @available(*, deprecated, message: "Deprecated")
    public extension View {
        func windowTitle(_ title: String) -> some View {
            WindowEnvironmentClosureView(content: self) { window in
                window.title = title
            }
        }

        func windowStyleMask(_ styleMask: NSWindow.StyleMask) -> some View {
            WindowEnvironmentClosureView(content: self) { window in
                print(window.styleMask)
                window.styleMask = styleMask
                print(window.styleMask)
            }
        }
    }

    // TODO: Can this be made completely generic?
    @available(*, deprecated, message: "Deprecated")
    public struct WindowEnvironmentClosureView<Content>: View where Content: View {
        public let content: Content
        public let closure: (NSWindow) -> Void

        @Environment(\.window)
        public var value: () -> NSWindow?

        public var body: some View {
            content.onAppear {
                guard let window = self.value() else {
                    return
                }
                self.closure(window)
            }
        }
    }
#endif
*/
