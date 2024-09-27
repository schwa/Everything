import Foundation

public func shlex(_ string: String) -> [String] {
    let scanner = Scanner(string: string)

    var result: [String] = []

    while scanner.isAtEnd == false {
        if let s = scanner.scanQuotedEscapedString() {
            result.append(s)
        } else if let s = scanner.scanUpToCharacters(from: .whitespaces) {
            result.append(s.trimmingCharacters(in: .whitespacesAndNewlines))
            _ = scanner.scanCharacters(from: .whitespaces)
        }
    }

    return result
}

public func assertChanging<Base, Result>(base: Base, _ keyPath: KeyPath<Base, some Equatable>, _ block: () throws -> Result) rethrows -> Result {
    let before = base[keyPath: keyPath]
    let result = try block()
    let after = base[keyPath: keyPath]
    assert(before != after)
    return result
}
