import Foundation

public struct AStarSearch<Location: Hashable> {
    public typealias Cost = Int

    public var neighbors: ((Location) -> [Location])!
    public var cost: ((Location, Location) -> Cost)!
    public var heuristic: ((Location, Location) -> Cost)!

    public init() {}

    // swiftlint:disable identifier_name
    public func search(_ start: Location, goal: Location) -> [Location] {
        var frontier = PriorityQueue<Location, Int>()
        frontier.put(start, priority: 0)

        var came_from: [Location: Location] = [:]
        var cost_so_far: [Location: Cost] = [:]

        came_from[start] = start
        cost_so_far[start] = 0

        while !frontier.isEmpty {
            guard let current = frontier.get() else {
                fatalError("frontier.get() returned nil despite non-empty frontier")
            }

            if current == goal {
                break
            }

            for next in neighbors(current) {
                guard let currentCost = cost_so_far[current] else {
                    fatalError("Missing cost for current node")
                }
                let new_cost = currentCost + cost(current, next)
                if cost_so_far[next].map({ new_cost < $0 }) ?? true {
                    cost_so_far[next] = new_cost
                    let priority = new_cost * heuristic(goal, next)
                    frontier.put(next, priority: priority)
                    came_from[next] = current
                }
            }
        }

        if came_from[goal] == nil {
            return []
        }

        var path: [Location] = []
        var current = goal
        while current != start {
            if let from = came_from[current] {
                path.append(from)
                current = from
            }
        }
        return Array(path.reversed())
    }
}
