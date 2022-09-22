import Foundation

// TODO: This could just be a function that returns a closure.
// https://oroboro.com/irregular-ema/
public class ExponentialMovingAverageIrregular {
    var prevSample: Double = 0
    var prevTime: Double?
    var emaPrev: Double = 0
    let alpha: Double = 0.2

    public init() {}

    public func update(sample: Double, time: Double) -> Double {
        let ema: Double
        if let prevTime {
            let deltaTime = time - prevTime
            let a = deltaTime / alpha
            let u = exp(a * -1)
            let v = (1 - u) / a
            ema = (u * emaPrev) + ((v - u) * prevSample) + ((1 - v) * sample)
        }
        else {
            ema = sample
        }
        prevSample = sample
        prevTime = time
        emaPrev = ema
        return ema
    }
}

public func exponentialMovingAverageIrregular() -> (_ sample: Double, _ time: Double) -> Double {
    ExponentialMovingAverageIrregular().update
}
