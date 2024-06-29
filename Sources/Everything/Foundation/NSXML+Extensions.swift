import Foundation

#if os(macOS)
extension XMLElement {
    subscript(name: String) -> XMLNode? {
        get {
            attribute(forName: name)
        }
        set {
            if let newValue {
                assert(name == newValue.name)
                addAttribute(newValue)
            } else {
                removeAttribute(forName: name)
            }
        }
    }
}
#endif
