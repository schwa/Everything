@testable import Everything
import XCTest

class AStarSearchTests: XCTestCase {

    // MARK: - Simple Grid Tests

    /// Test pathfinding on a simple 2D grid with no obstacles
    func testSimpleGridPath() {
        typealias Point = SIMD2<Int>

        var search = AStarSearch<Point>()

        // 5x5 grid, all traversable
        let gridSize = 5

        search.neighbors = { point in
            let offsets: [Point] = [Point(0, 1), Point(0, -1), Point(1, 0), Point(-1, 0)]
            return offsets.compactMap { offset in
                let neighbor = point &+ offset
                guard neighbor.x >= 0, neighbor.x < gridSize,
                      neighbor.y >= 0, neighbor.y < gridSize else {
                    return nil
                }
                return neighbor
            }
        }

        search.cost = { _, _ in 1 }

        // Manhattan distance heuristic
        search.heuristic = { goal, current in
            abs(goal.x - current.x) + abs(goal.y - current.y)
        }

        let start = Point(0, 0)
        let goal = Point(4, 4)
        let path = search.search(start, goal: goal)

        // Path should exist and be optimal (length 8 for Manhattan path from 0,0 to 4,4)
        XCTAssertFalse(path.isEmpty)
        XCTAssertEqual(path.count, 8) // 8 steps from start to one before goal
        XCTAssertEqual(path.first, start)
    }

    /// Test that search returns empty path when goal is unreachable
    func testUnreachableGoal() {
        typealias Point = SIMD2<Int>

        var search = AStarSearch<Point>()

        // No neighbors - goal is unreachable
        search.neighbors = { _ in [] }
        search.cost = { _, _ in 1 }
        search.heuristic = { _, _ in 1 }

        let start = Point(0, 0)
        let goal = Point(5, 5)
        let path = search.search(start, goal: goal)

        XCTAssertTrue(path.isEmpty)
    }

    /// Test when start equals goal
    func testStartEqualsGoal() {
        typealias Point = SIMD2<Int>

        var search = AStarSearch<Point>()

        search.neighbors = { _ in [] }
        search.cost = { _, _ in 1 }
        search.heuristic = { _, _ in 0 }

        let point = Point(3, 3)
        let path = search.search(point, goal: point)

        // When start == goal, path should be empty (no steps needed)
        XCTAssertTrue(path.isEmpty)
    }

    /// Test pathfinding with obstacles
    func testPathWithObstacles() {
        typealias Point = SIMD2<Int>

        var search = AStarSearch<Point>()

        // 5x5 grid with a wall in the middle
        let gridSize = 5
        let obstacles: Set<Point> = [
            Point(2, 0), Point(2, 1), Point(2, 2), Point(2, 3)
        ]

        search.neighbors = { point in
            let offsets: [Point] = [Point(0, 1), Point(0, -1), Point(1, 0), Point(-1, 0)]
            return offsets.compactMap { offset in
                let neighbor = point &+ offset
                guard neighbor.x >= 0, neighbor.x < gridSize,
                      neighbor.y >= 0, neighbor.y < gridSize,
                      !obstacles.contains(neighbor) else {
                    return nil
                }
                return neighbor
            }
        }

        search.cost = { _, _ in 1 }
        search.heuristic = { goal, current in
            abs(goal.x - current.x) + abs(goal.y - current.y)
        }

        let start = Point(0, 0)
        let goal = Point(4, 0)
        let path = search.search(start, goal: goal)

        // Path should exist but go around the wall
        XCTAssertFalse(path.isEmpty)
        // Verify no obstacles in path
        for point in path {
            XCTAssertFalse(obstacles.contains(point))
        }
    }

    /// Test with varying edge costs
    func testVaryingCosts() {
        typealias Point = SIMD2<Int>

        var search = AStarSearch<Point>()

        let gridSize = 3
        // Make the middle row expensive
        let expensiveRow = 1

        search.neighbors = { point in
            let offsets: [Point] = [Point(0, 1), Point(0, -1), Point(1, 0), Point(-1, 0)]
            return offsets.compactMap { offset in
                let neighbor = point &+ offset
                guard neighbor.x >= 0, neighbor.x < gridSize,
                      neighbor.y >= 0, neighbor.y < gridSize else {
                    return nil
                }
                return neighbor
            }
        }

        search.cost = { _, to in
            to.y == expensiveRow ? 100 : 1
        }

        search.heuristic = { goal, current in
            abs(goal.x - current.x) + abs(goal.y - current.y)
        }

        let start = Point(0, 0)
        let goal = Point(2, 0)
        let path = search.search(start, goal: goal)

        XCTAssertFalse(path.isEmpty)
    }

    // MARK: - Graph Tests

    /// Test on a simple graph (not a grid)
    func testSimpleGraph() {
        var search = AStarSearch<String>()

        // Simple graph: A -> B -> C -> D
        //                    \-> E -/
        let graph: [String: [String]] = [
            "A": ["B"],
            "B": ["C", "E"],
            "C": ["D"],
            "E": ["D"],
            "D": []
        ]

        search.neighbors = { node in graph[node] ?? [] }
        search.cost = { _, _ in 1 }
        search.heuristic = { _, _ in 1 }

        let path = search.search("A", goal: "D")

        XCTAssertFalse(path.isEmpty)
        XCTAssertEqual(path.first, "A")
        // Path should be A -> B -> (C or E) -> (before D)
        XCTAssertEqual(path.count, 3)
    }

    /// Test adjacent nodes (one step path)
    func testAdjacentNodes() {
        var search = AStarSearch<String>()

        let graph: [String: [String]] = [
            "A": ["B"],
            "B": []
        ]

        search.neighbors = { node in graph[node] ?? [] }
        search.cost = { _, _ in 1 }
        search.heuristic = { _, _ in 1 }

        let path = search.search("A", goal: "B")

        XCTAssertEqual(path.count, 1)
        XCTAssertEqual(path.first, "A")
    }
}
