import CoreGraphics

// TODO: Move
public protocol ColorConvertible {
    var color: CGColor { get }
}

extension Double: ColorConvertible {
    public var color: CGColor {
        let gray = CGFloat(self)
        return CGColor(red: gray, green: gray, blue: gray, alpha: 1.0)
    }
}

extension Bool: ColorConvertible {
    public var color: CGColor {
        let gray: CGFloat = self ? 1.0 : 0.0
        return CGColor(red: gray, green: gray, blue: gray, alpha: 1.0)
    }
}
