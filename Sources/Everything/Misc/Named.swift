public protocol Named {
    var name: String { get }
}

public extension Named where Self: Identifiable {
    var id: String { name }
}

public extension Array where Element: Named {
    subscript(name: String) -> Element? {
        first { $0.name == name }
    }
}

public extension Array where Element: Identifiable {
    subscript(id: Element.ID) -> Element? {
        first { $0.id == id }
    }
}
