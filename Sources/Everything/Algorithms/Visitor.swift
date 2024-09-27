import Foundation

public struct Visitor<Node, Children>: Sequence where Children: Sequence, Children.Element == Node {
    public enum Order {
        case preorder // (self, children)
        case postorder // (children, self)
    }

    let _makeIterator: () -> AnyIterator<Node>

    public init(root: Node, children: KeyPath<Node, Children>, order: Order = .preorder) {
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
                    if !s.isEmpty {
                        let current = s.popLast()
                        out.append(current!)
                        s.append(contentsOf: current![keyPath: children])
                        return out.popLast()
                    }
                    return nil
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
