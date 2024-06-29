#if os(macOS)
import AppKit
import Foundation

public extension NSStoryboard {
    convenience init(name: String) {
        self.init(name: name, bundle: nil)
    }
}
#endif // os(macOS)
