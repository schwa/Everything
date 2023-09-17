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

@available(*, deprecated, message: "Use https://github.com/schwa/ApproximateEquality")
public protocol FuzzyEquatable {
    static func ==% (lhs: Self, rhs: Self) -> Bool
}

infix operator ==%: ComparisonPrecedence

// MARK: Fuzzy inequality

infix operator !=%: ComparisonPrecedence

// swiftlint:disable:next static_operator
@available(*, deprecated, message: "Use https://github.com/schwa/ApproximateEquality")
public func !=% <T: FuzzyEquatable>(lhs: T, rhs: T) -> Bool {
    !(lhs ==% rhs)
}

// MARK: Float

@available(*, deprecated, message: "Use https://github.com/schwa/ApproximateEquality")
extension Float: FuzzyEquatable {
    public static func ==% (lhs: Float, rhs: Float) -> Bool {
        equal(lhs, rhs, accuracy: .ulpOfOne)
    }
}

// MARK: Double

@available(*, deprecated, message: "Use https://github.com/schwa/ApproximateEquality")
extension Double: FuzzyEquatable {
    public static func ==% (lhs: Double, rhs: Double) -> Bool {
        equal(lhs, rhs, accuracy: .ulpOfOne)
    }
}

// MARK: CGFloat

@available(*, deprecated, message: "Use https://github.com/schwa/ApproximateEquality")
extension CGFloat: FuzzyEquatable {
    public static func ==% (lhs: CGFloat, rhs: CGFloat) -> Bool {
        equal(lhs, rhs, accuracy: .ulpOfOne)
    }
}

// MARK: CGPoint

@available(*, deprecated, message: "Use https://github.com/schwa/ApproximateEquality")
extension CGPoint: FuzzyEquatable {
    public static func ==% (lhs: CGPoint, rhs: CGPoint) -> Bool {
        lhs.x ==% rhs.x && lhs.y ==% rhs.y
    }
}
