import Foundation

internal extension Int {
    static func addIgnoringOverflow(_ lhs: Int, _ rhs: Int) -> Int {
        lhs.addingReportingOverflow(rhs).0
    }
}

public func hash_combine(_ lhs: Int, _ rhs: Int) -> Int {
    // 0x9e3779b9
    // http://stackoverflow.com/questions/5889238/why-is-xor-the-default-way-to-combine-hashes#5889254
    let seed = 0x9E3_779B_97F4_A7C1

//    return lhs ^ rhs + seed + (lhs << 6) + (lhs >> 2)
    return lhs ^ Int.addIgnoringOverflow(Int.addIgnoringOverflow(rhs, seed), Int.addIgnoringOverflow(lhs << 6, lhs >> 2))
}
