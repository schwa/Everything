import SwiftUI

@available(*, deprecated, message: "Use List")
public class Outline<Element>: ObservableObject where Element: Hashable {
    public class Item: Identifiable, ObservableObject, Hashable {
        public static func == (lhs: Outline<Element>.Item, rhs: Outline<Element>.Item) -> Bool {
            lhs.content == rhs.content
        }

        public func hash(into hasher: inout Hasher) {
            content.hash(into: &hasher)
        }

        public private(set) weak var outline: Outline!
        public internal(set) var index: Int
        public var content: Element
        public let depth: Int
        public let isLeaf: Bool

        @Published
        public var expanded: Bool {
            willSet {
                if !expanded {
                    outline.expand(item: self)
                }
                else {
                    outline.collapse(item: self)
                }
            }
        }

        public init(outline: Outline, index: Int, content: Element, depth: Int = 0, isLeaf: Bool = false, expanded: Bool = false) {
            self.outline = outline
            self.index = index
            self.content = content
            self.depth = depth
            self.isLeaf = isLeaf
            self.expanded = expanded
        }
    }

    public typealias Items = [Item]

    @Published
    public var items = Items()
    public private(set) var children: (Outline, Item) -> [Item]

    public init(children: @escaping (Outline, Item) -> [Item]) {
        self.children = children
    }

    public func expand(item: Item) {
        assert(item.expanded == false)
        let index = item.index
        let children = children(self, item)
        items.insert(contentsOf: children, at: index + 1)
        reindex()
    }

    public func collapse(item: Item) {
        assert(item.expanded == true)
        let index = item.index
        let firstIndex = items[(index + 1)...].firstIndex { $0.depth <= item.depth } ?? items.endIndex
        items.removeSubrange((index + 1) ..< firstIndex)
        reindex()
    }

    private func reindex() {
        for index in items.indices {
            items[index].index = index
        }
    }
}

// MARK: -

@available(*, deprecated, message: "Use native")
public struct DisclosureButton: View {
    @Binding
    public var disclosed: Bool

    public var recursiveDisclose: (() -> Void)?

    public var body: some View {
        Button(action: {
            if self.disclosed == false {
                self.disclosed = true
                #if os(macOS)
                    if isAltDown() {
                        self.recursiveDisclose?()
                    }
                #endif
            }
            else {
                self.disclosed = false
            }
        }, label: {
            ZStack {
                #if os(macOS)
                    Text("􀄧").hidden(self.disclosed)
                    Text("􀄥").hidden(!self.disclosed)
                #elseif os(iOS)
                    Image(systemName: "arrowtriangle.right.fill").hidden(self.disclosed)
                    Image(systemName: "arrowtriangle.down.fill").hidden(!self.disclosed)
                #endif
            }
        })
        .buttonStyle(BorderlessButtonStyle())
    }
}

// TODO: Move
private extension View {
    func hidden(_ hidden: Bool) -> some View {
        ZStack {
            hidden ? nil : self
            hidden ? self.hidden() : nil
        }
    }
}

#if os(macOS)
    @MainActor
    func isAltDown() -> Bool {
        NSApp.currentEvent?.modifierFlags.contains(.option) ?? false
    }
#endif

@available(*, deprecated, message: "Use native")
public struct OutlineRow<Element, Content>: View where Element: Hashable, Content: View {
    public typealias Item = Outline<Element>.Item
    let item: Item
    let content: (Element) -> Content

    @Binding
    var disclosed: Bool

    public init(item: Item, content: @escaping (Element) -> Content) {
        self.item = item
        _disclosed = Binding(get: {
            item.expanded
        }, set: {
            item.expanded = $0
        })
        self.content = content
    }

    public var body: some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: CGFloat(item.depth) * 20)
            HStack {
                DisclosureButton(disclosed: $disclosed, recursiveDisclose: nil).hidden(item.isLeaf)
                content(item.content)
            }
            Spacer()
        } // .background(item.index % 2 == 0 ? Color.clear : Color.blue.opacity(0.05))
    }
}
