import Foundation

// TODO: This could just be a function that returns a closure.
// https://oroboro.com/irregular-ema/
public struct ExponentialMovingAverageIrregular {
    private typealias Sample = (time: Double, value: Double)

    public private(set) var exponentialMovingAverage: Double = 0
    private let alpha: Double
    private var lastSample: Sample?

    public init(alpha: Double = 0.2) {
        self.alpha = alpha
    }

    @discardableResult
    public mutating func update(time: Double, value: Double) -> Double {
        let newMovingAverage: Double
        if let lastSample {
            let deltaTime = time - lastSample.time
            let a = deltaTime / alpha
            let u = exp(a * -1)
            let v = (1 - u) / a
            newMovingAverage = (u * exponentialMovingAverage) + ((v - u) * lastSample.value) + ((1 - v) * value)
        }
        else {
            newMovingAverage = value
        }
        lastSample = (time: time, value: value)
        exponentialMovingAverage = newMovingAverage
        return exponentialMovingAverage
    }
}
