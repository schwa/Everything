#if os(macOS)
    import AppKit
    import Foundation
    import SwiftUI

    @MainActor
    private class AppDelegate<T>: NSObject, NSApplicationDelegate, NSWindowDelegate where T: View {
        let window: NSWindow
        let root: T

        init(title: String? = nil, root: T) {
            self.root = root
            window = NSWindow()
            window.title = title ?? "My Swift Script"
        }

        func applicationDidFinishLaunching(_ notification: Notification) {
            let appMenu = NSMenuItem()
            appMenu.submenu = NSMenu()
            appMenu.submenu!.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            let mainMenu = NSMenu(title: "My Swift Script")
            mainMenu.addItem(appMenu)
            NSApplication.shared.mainMenu = mainMenu

            let size = CGSize(width: 480, height: 270)
            window.setContentSize(size)
            window.styleMask = [.closable, .miniaturizable, .resizable, .titled]
            window.delegate = self

            let view = NSHostingView(rootView: root)
            view.frame = CGRect(origin: .zero, size: size)
            view.autoresizingMask = [.height, .width]
            window.contentView!.addSubview(view)
            window.center()
            window.makeKeyAndOrderFront(window)

            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
        }

        func windowWillClose(_ notification: Notification) {
            NSApplication.shared.terminate(0)
        }
    }

    public extension NSApplication {
        func run(title: String? = nil, _ content: () -> some View) {
            let appDelegate = AppDelegate(title: title, root: content())
            delegate = appDelegate
            run()
        }
    }
#endif
