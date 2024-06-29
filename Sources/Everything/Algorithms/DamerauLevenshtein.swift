import Foundation

public protocol StringDifferenceAlgorithm {
    static func distance(_ a: String, _ b: String) -> Int
}

public enum DamerauLevenshteinAlgorithm: StringDifferenceAlgorithm {
    public static func distance(_ a: String, _ b: String) -> Int {
        distance(Array(a), Array(b))
    }

    public static func distance(_ a: [Character], _ b: [Character]) -> Int {
        func len(_ x: [Character]) -> Int {
            x.count
        }
        if min(a.count, b.count) == 0 {
            return max(a.count, b.count)
        }
        let indicator = a[wrapping: -1] == b[wrapping: -1] ? 0 : 1
        let new_a = Array(a.dropLast())
        let new_b = Array(b.dropLast())
        let another_a = Array(a.dropLast(2))
        let another_b = Array(b.dropLast(2))
        if len(a) > 1, len(b) > 1, a[wrapping: -1] == b[wrapping: -2], a[wrapping: -2] == b[wrapping: -1] {
            return min(distance(a, new_b) + 1, distance(new_a, b) + 1, distance(new_a, new_b) + indicator, distance(another_a, another_b) + 1)
        }
        return min(distance(new_a, b) + 1, distance(a, new_b) + 1, distance(new_a, new_b) + indicator)
    }
}
