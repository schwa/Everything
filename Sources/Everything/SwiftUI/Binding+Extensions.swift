import SwiftUI

public extension Binding {
    func unsafeBinding<V>() -> Binding<V> where Value == V? {
        Binding<V> {
            wrappedValue!
        } set: {
            wrappedValue = $0
        }
    }

    func unwrappingRebound<T>(default: @escaping () -> T) -> Binding<T> where Value == T? {
        Binding<T>(get: {
            self.wrappedValue ?? `default`()
        }, set: {
            self.wrappedValue = $0
        })
    }

    // TODO: Rename
    func withUnsafeBinding<V, R>(_ block: (Binding<V>) throws -> R) rethrows -> R? where Value == V? {
        if wrappedValue != nil {
            return try block(Binding<V> { wrappedValue! } set: { wrappedValue = $0 })
        }
        else {
            return nil
        }
    }
}

public extension Binding where Value == SwiftUI.Angle {
    init <F>(radians: Binding<F>) where F: BinaryFloatingPoint {
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
            return CGColor(colorSpace: colorSpace, components: [CGFloat(simd.wrappedValue[0]), CGFloat(simd.wrappedValue[1]), CGFloat(simd.wrappedValue[2])])!
        }, set: { newValue in
            let newValue = newValue.converted(to: colorSpace, intent: .defaultIntent, options: nil)!
            let components = newValue.components!
            simd.wrappedValue = SIMD3<Float>(Float(components[0]), Float(components[1]), Float(components[2]))
        })
    }
}

public extension Binding where Value == Double {
    init <Other>(_ binding: Binding<Other>) where Other: BinaryFloatingPoint {
        self.init {
            return Double(binding.wrappedValue)
        } set: { newValue in
            binding.wrappedValue = Other(newValue)
        }
    }
}

