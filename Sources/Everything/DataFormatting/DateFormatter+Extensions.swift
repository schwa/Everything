import Foundation

@available(*, deprecated, message: "Use FormatStyle() and friends.")
public extension DateFormatter {
    static let formatter: DateFormatter = {
        let s = DateFormatter()
        s.dateStyle = .short
        s.timeStyle = .short
        return s
    }()

    static let dateFormatter: DateFormatter = {
        let s = DateFormatter()
        s.dateStyle = .short
        s.timeStyle = .none
        return s
    }()

    static let timeFormatter: DateFormatter = {
        let s = DateFormatter()
        s.dateStyle = .none
        s.timeStyle = .short
        return s
    }()

    // http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
    convenience init(format: String) {
        self.init()
        dateFormat = format
    }
}
