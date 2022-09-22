import CoreGraphics

#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

public extension CGColor {
    #if os(macOS)
        static func HSV(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1.0) -> CGColor {
            NSColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha).cgColor
        }

    #elseif os(iOS)
        static func HSV(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1.0) -> CGColor {
            UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha).cgColor
        }
    #endif

    func withAlphaComponent(_ alpha: CGFloat) -> CGColor {
        copy(alpha: alpha)!
    }

    func blended(withFraction fraction: CGFloat, of other: CGColor) -> CGColor {
        unimplemented()
    }
}
