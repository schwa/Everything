import Foundation

public extension Date {
    func adding(minutes: Int) -> Date {
        guard let date = Calendar.current.date(byAdding: DateComponents(minute: minutes), to: self) else {
            fatalError("Failed to add \(minutes) minutes to \(self)")
        }
        return date
    }
}

public extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        lhs.timeIntervalSince(rhs)
    }

    static func + (lhs: Date, rhs: TimeInterval) -> Date {
        lhs.addingTimeInterval(rhs)
    }
}

public extension Date {
    func startOfDay(in calendar: Calendar? = nil) -> Date {
        let calender = calendar ?? Calendar.current
        let components = calender.dateComponents([.era, .year, .month, .day, .timeZone], from: self)
        guard let date = calender.date(from: components) else {
            fatalError("Failed to compute start of day for \(self)")
        }
        return date
    }

    func addingDays(_ days: Int, in calendar: Calendar? = nil) -> Date {
        let calendar: Calendar = calendar ?? Calendar.current
        var components = DateComponents()
        components.day = days
        guard let date = calendar.date(byAdding: components, to: self) else {
            fatalError("Failed to add \(days) days to \(self)")
        }
        return date
    }
}
