import CoreGraphics

public func equal(_ lhs: CGFloat, _ rhs: CGFloat, accuracy: CGFloat) -> Bool {
    abs(rhs - lhs) <= accuracy
}

public func equal(_ lhs: Float, _ rhs: Float, accuracy: Float) -> Bool {
    abs(rhs - lhs) <= accuracy
}

public func equal(_ lhs: Double, _ rhs: Double, accuracy: Double) -> Bool {
    abs(rhs - lhs) <= accuracy
}

// MARK: Fuzzy equality

public protocol FuzzyEquatable {
    static func ==% (lhs: Self, rhs: Self) -> Bool
}

infix operator ==%: ComparisonPrecedence

// MARK: Fuzzy inequality

infix operator !=%: ComparisonPrecedence

// swiftlint:disable:next static_operator
public func !=% <T: FuzzyEquatable>(lhs: T, rhs: T) -> Bool {
    !(lhs ==% rhs)
}

// MARK: Float

extension Float: FuzzyEquatable {
    public static func ==% (lhs: Float, rhs: Float) -> Bool {
        equal(lhs, rhs, accuracy: .ulpOfOne)
    }
}

// MARK: Double

extension Double: FuzzyEquatable {
    public static func ==% (lhs: Double, rhs: Double) -> Bool {
        equal(lhs, rhs, accuracy: .ulpOfOne)
    }
}

// MARK: CGFloat

extension CGFloat: FuzzyEquatable {
    public static func ==% (lhs: CGFloat, rhs: CGFloat) -> Bool {
        equal(lhs, rhs, accuracy: .ulpOfOne)
    }
}

// MARK: CGPoint

extension CGPoint: FuzzyEquatable {
    public static func ==% (lhs: CGPoint, rhs: CGPoint) -> Bool {
        lhs.x ==% rhs.x && lhs.y ==% rhs.y
    }
}
