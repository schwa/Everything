import Foundation

let superscripts = ["⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"]

public struct Polynomial {
    public struct Term {
        public let coefficient: Double
        public struct Variable {
            public let symbol: Character
            public let exponent: Int
        }

        public let variables: [Variable]
    }

    public let terms: [Term]
}

extension Polynomial: CustomStringConvertible {
    public var description: String {
        terms.map(\.description).joined(separator: " + ")
    }
}

extension Polynomial.Term: CustomStringConvertible {
    public var description: String {
        "\(coefficient)\(variables.map(\.description).joined())"
    }
}

extension Polynomial.Term.Variable: CustomStringConvertible {
    public var description: String {
        "\(symbol)\(superscripts[exponent])"
    }
}

// let polynomial = Polynomial(terms: [
//    .init(coefficient: 1, variables: [.init(symbol: "x", exponent: 2)])
// ])
//
// print(polynomial)
