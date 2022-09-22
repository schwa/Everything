import Foundation

public struct Visitor <Node, Children>: Sequence where Children: Sequence, Children.Element == Node {
    public enum Order {
        case preorder // (self, children)
        case postorder // (children, self)
    }

    let _makeIterator: () -> AnyIterator<Node>

    public init(root: Node, children: KeyPath <Node, Children>, order: Order = .preorder) {
        switch order {
        case .preorder:
            _makeIterator = {
                var stack: [Node] = []
                var current: Node? = root
                return AnyIterator<Node> {
                    guard !stack.isEmpty || current != nil else {
                        return nil
                    }
                    let result = current
                    // TODO: .reversed() is inefficient
                    stack.append(contentsOf: current![keyPath: children].reversed())
                    current = stack.popLast()
                    return result
                }
            }
        case .postorder:
            // TODO: BROKEN - returns in reverse order
            _makeIterator = {
                var out: [Node] = []
                var s: [Node] = [root]
                return AnyIterator<Node> {
                    if !out.isEmpty {
                        return out.popLast()
                    }
                    else if !s.isEmpty {
                        let current = s.popLast()
                        out.append(current!)
                        s.append(contentsOf: current![keyPath: children])
                        return out.popLast()
                    }
                    else {
                        return nil
                    }
                }
            }
        }
    }
    public func makeIterator() -> AnyIterator<Node> {
        _makeIterator()
    }
}

private extension Array {
    mutating func popFirst() -> Element? {
        defer {
            self = Array(self.dropFirst())
        }
        return first
    }
}

/*

// https://en.wikipedia.org/wiki/Tree_traversal

class Node: CustomStringConvertible, ExpressibleByStringLiteral {
    weak var parent: Node?
    var children: [Node]
    let label: String

    init(_ label: String, parent: Node? = nil, _ children: [Node] = []) {
        self.label = label
        self.parent = parent
        self.children = children
    }

    var description: String {
        return label
    }

    required init(stringLiteral value: String) {
        self.label = value
        self.parent = nil
        self.children = []
    }
}

 Pre-order (node visited at position red ●):
 F, B, A, D, C, E, G, I, H;
 In-order (node visited at position green ●):
 A, B, C, D, E, F, G, H, I;
 Post-order (node visited at position blue ●):
 A, C, E, D, B, H, I, G, F.


let root = Node("F", [
    Node("B", [
        "A",
        Node("D", ["C", "E"])
    ]),
    Node("G", [
        Node("I", ["H"])
    ])
])



print(Array(Visitor(root: root, children: \Node.children)))
print(Array(Visitor(root: root, children: \Node.children, order: .postorder)))

*/
