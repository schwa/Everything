import simd
import SwiftUI

public extension Color {
    func legibleComplement() -> Color? {
        guard let cgColor else {
            return nil
        }
        guard let converted = cgColor.converted(to: CGColorSpace(name: CGColorSpace.linearSRGB)!, intent: .defaultIntent, options: nil) else {
            fatalError("Could not convert color to colorspace")
        }
        let components = converted.components!
        let r = components[0]
        let g = components[1]
        let b = components[2]
        let brightness = r * 0.299 + g * 0.587 + b * 0.114
        if brightness < 0.5 {
            return Color.white
        }
        return Color.black
    }
}

public extension Color {
    init(_ v: SIMD3<Double>) {
        self = Color(.displayP3, red: v.x, green: v.y, blue: v.z, opacity: 1.0)
    }
}

// https://iquilezles.org/www/articles/palettes/palettes.htm
public struct InigoColourPalette {
    init(_ a: SIMD3<Double>, _ b: SIMD3<Double>, _ c: SIMD3<Double>, _ d: SIMD3<Double>) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
    }

    let a: SIMD3<Double>
    let b: SIMD3<Double>
    let c: SIMD3<Double>
    let d: SIMD3<Double>

    func color(at t: Double) -> SIMD3<Double> {
        a + b * cos(.pi * 2 * (c * t + d))
    }

    static let example1 = Self([0.5, 0.5, 0.5], [0.5, 0.5, 0.5], [1.0, 1.0, 1.0], [0.00, 0.33, 0.67])
    static let example2 = Self([0.5, 0.5, 0.5], [0.5, 0.5, 0.5], [1.0, 1.0, 1.0], [0.00, 0.10, 0.20])
    static let example3 = Self([0.5, 0.5, 0.5], [0.5, 0.5, 0.5], [1.0, 1.0, 1.0], [0.30, 0.20, 0.20])
    static let example4 = Self([0.5, 0.5, 0.5], [0.5, 0.5, 0.5], [1.0, 1.0, 0.5], [0.80, 0.90, 0.30])
    static let example5 = Self([0.5, 0.5, 0.5], [0.5, 0.5, 0.5], [1.0, 0.7, 0.4], [0.00, 0.15, 0.20])
    static let example6 = Self([0.5, 0.5, 0.5], [0.5, 0.5, 0.5], [2.0, 1.0, 0.0], [0.50, 0.20, 0.25])
    static let example7 = Self([0.8, 0.5, 0.4], [0.2, 0.4, 0.2], [2.0, 1.0, 1.0], [0.00, 0.25, 0.25])
    static let allExamples: [Self] = [.example1, .example2, .example3, .example4, .example5, .example6, .example7]
}
