import SwiftUI

public extension Binding {
    func unsafeBinding<V>() -> Binding<V> where Value == V?, Value: Sendable {
        Binding<V> {
            guard let value = wrappedValue else {
                fatalError("Binding wrappedValue unexpectedly nil")
            }
            return value
        } set: {
            wrappedValue = $0
        }
    }

    func unwrappingRebound<T>(default: @escaping @Sendable () -> T) -> Binding<T> where Value == T?, Value: Sendable {
        Binding<T>(get: {
            self.wrappedValue ?? `default`()
        }, set: {
            self.wrappedValue = $0
        })
    }

    // TODO: Rename
    func withUnsafeBinding<V, R>(_ block: (Binding<V>) throws -> R) rethrows -> R? where Value == V?, Value: Sendable {
        if wrappedValue != nil {
            return try block(Binding<V> {
                guard let value = wrappedValue else {
                    fatalError("Binding wrappedValue unexpectedly nil")
                }
                return value
            } set: { wrappedValue = $0 })
        }
        return nil
    }
}

public extension Binding where Value == SwiftUI.Angle {
    init <F>(radians: Binding<F>) where F: BinaryFloatingPoint & Sendable {
        self = .init(get: {
            .radians(Double(radians.wrappedValue))
        }, set: {
            radians.wrappedValue = F($0.radians)
        })
    }
}

public extension Binding where Value == CGColor {
    init(simd: Binding<SIMD3<Float>>, colorSpace: CGColorSpace) {
        self = .init(get: {
            guard let color = CGColor(colorSpace: colorSpace, components: [CGFloat(simd.wrappedValue[0]), CGFloat(simd.wrappedValue[1]), CGFloat(simd.wrappedValue[2])]) else {
                fatalError("Failed to create CGColor from SIMD3")
            }
            return color
        }, set: { newValue in
            guard let converted = newValue.converted(to: colorSpace, intent: .defaultIntent, options: nil),
                  let components = converted.components else {
                fatalError("Failed to convert CGColor to target color space")
            }
            simd.wrappedValue = SIMD3<Float>(Float(components[0]), Float(components[1]), Float(components[2]))
        })
    }
}

public extension Binding where Value == Double {
    init <Other>(_ binding: Binding<Other>) where Other: BinaryFloatingPoint & Sendable {
        self.init {
            Double(binding.wrappedValue)
        } set: { newValue in
            binding.wrappedValue = Other(newValue)
        }
    }
}
