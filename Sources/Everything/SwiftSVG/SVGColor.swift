#if os(macOS)
    import AppKit
#endif // os(macOS)

public struct SVGColor: ColorProtocol {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = Double(red) / 255
        self.green = Double(green) / 255
        self.blue = Double(blue) / 255
    }

    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}

// MARK: -

#if os(macOS)
    public extension SVGColor {
        func toNSColor() -> NSColor {
            NSColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
        }
    }
#endif // os(macOS)
