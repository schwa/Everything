public enum RadiansTag {}

public typealias Radians<Value: BinaryFloatingPoint> = Tagged<RadiansTag, Value>

// MARK: -

public enum DegreesTag {}

public typealias Degrees<Value: BinaryFloatingPoint> = Tagged<DegreesTag, Value>

// MARK: -

public extension Tagged where Kind == RadiansTag, Value: BinaryFloatingPoint {
    var degrees: Degrees<Value> {
        Degrees<Value>(rawValue: rawValue * 180 / .pi)
    }
}

public extension Tagged where Kind == DegreesTag, Value: BinaryFloatingPoint {
    var radians: Radians<Value> {
        Radians<Value>(rawValue: rawValue * .pi / 180)
    }
}
