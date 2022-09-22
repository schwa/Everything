@available(*, deprecated, message: "Use Visitor")
public struct Walker<T> {
    public struct State {
        public var depth: Int = 0
        public var stack: [T] = []

        public func filler(_ string: String = " ") -> String {
            String(repeating: string, count: depth)
        }
    }

    public typealias Children = (_ node: T) -> [T]?
    public typealias StatelessVisitor = (_ node: T, _ depth: Int) -> Void
    public typealias StatefulVisitor = (_ node: T, _ state: State) -> Void

    public let childrenBlock: Children!

    public init(childrenBlock: @escaping Children) {
        self.childrenBlock = childrenBlock
    }

    public func walk(_ node: T, visitor: StatefulVisitor) {
        walk(node, state: State(), visitor: visitor)
    }

    public func walk(_ node: T, state: State, visitor: StatefulVisitor) {
        var state = state
        visitor(node, state)
        state = State(depth: state.depth + 1, stack: state.stack + [node])
        if let children = childrenBlock(node) {
            for child in children {
                walk(child, state: state, visitor: visitor)
            }
        }
    }

    public func walk(_ node: T, visitor: StatelessVisitor) {
        walk(node, depth: 0, visitor: visitor)
    }

    func walk(_ node: T, depth: Int, visitor: StatelessVisitor) {
        visitor(node, depth)
        if let children = childrenBlock(node) {
            for child in children {
                walk(child, depth: depth + 1, visitor: visitor)
            }
        }
    }
}

/*

// MARK: Example

// MARK: Types
class Node <T> {
var value: T
var children: [Node <T>] = []

init(_ value: T) {
self.value = value
}
}

typealias StringNode = Node <String>

// MARK: Setup
let root = StringNode("Hello world")
root.children = [ StringNode("Child A"), StringNode("Child B") ]

// MARK: Walk
let walker = Walker <StringNode> () {
node in
return node.children
}

walker.walk(root) {
(node: StringNode, depth: Int) in
print("\(depth): \(node)")
}

walker.walk(root) {
(node: StringNode, state: _State <StringNode>) in
let filler = state.filler("\t")
print("\(filler)\(node)\(state.stack)")
}

*/
