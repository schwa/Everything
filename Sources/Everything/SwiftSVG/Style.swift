// See ColorPalette
// public class ColorPalette_ {
// }

public class Style {
    init(elements: [StyleElement]) {
    }
}

public enum StyleElement {
    case strokeColor(SVGColor)
    case fillColor(SVGColor)
    case lineWidth(Double)
}
