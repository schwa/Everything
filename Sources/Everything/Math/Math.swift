import CoreGraphics
import Foundation

// MARK: Math

precedencegroup ExponentPrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator **: ExponentPrecedence

// There is no generic pow<> so we're forced to create one ** for each BinaryFloatingPoint type

extension Float {
    static func ** (lhs: Float, rhs: Float) -> Float {
        if rhs == 2 {
            return lhs * lhs
        }
        return pow(lhs, rhs)
    }
}

public extension Double {
    static func ** (lhs: Double, rhs: Double) -> Double {
        if rhs == 2 {
            return lhs * lhs
        }
        return pow(lhs, rhs)
    }
}

public extension CGFloat {
    static func ** (lhs: CGFloat, rhs: CGFloat) -> CGFloat {
        if rhs == 2 {
            return lhs * lhs
        }
        return pow(lhs, rhs)
    }
}

// MARK: -

public func log(_ value: Float, base: Float) -> Float {
    log(value) / log(base)
}

public func log(_ value: Double, base: Double) -> Double {
    log(value) / log(base)
}

// MARK: Degrees/Radians

// In the spirit of UInt(bigEndian: ) etc

public extension FloatingPoint {
    init(radians: Self) {
        self = radians
    }

    init(degrees: Self) {
        self = degrees * .pi / 180
    }

    var radians: Self {
        self
    }

    var degrees: Self {
        self * 180 / .pi
    }
}

// Basic functions

/*
```swift doctest
radiansToDegrees(degreesToRadians(90)) // 90
```
*/
public func degreesToRadians<F>(_ value: F) -> F where F: FloatingPoint {
    value * .pi / 180
}

public func radiansToDegrees<F>(_ value: F) -> F where F: FloatingPoint {
    value * 180 / .pi
}

// MARK: -

/*
```swift doctest
divup(dividend: 10, divisor: 3) // 4
```
*/
public func divup<T>(dividend: T, divisor: T) -> T where T: BinaryInteger {
    (dividend + (divisor - 1)) / divisor
}

public func round(_ value: CGFloat, decimal: Int) -> CGFloat {
    let e10n = pow(10.0, CGFloat(clamp(decimal, lower: -6, upper: 7)))
    let fl = floor(e10n * value + 0.5)
    return fl / e10n
}

public extension Float {
    var radiansToDegrees: Self {
        Everything.radiansToDegrees(self)
    }

    func formatted() -> String {
        let f = NumberFormatter()
        f.maximumSignificantDigits = 4
        return f.string(for: self)!
    }
}
