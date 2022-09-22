import Foundation

public extension NumberFormatter {
    static var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = .max
        return formatter
    }
}
