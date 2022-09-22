import Combine
import CoreLocation
import Foundation

public class CoreLocationManager: NSObject, CLLocationManagerDelegate {
    public static let shared = CoreLocationManager()

    public let manager = CLLocationManager()

    private let _location = PassthroughSubject<CLLocation, Error>()
    public var location: AnyPublisher<CLLocation, Error> {
        manager.startUpdatingLocation()
        return _location.eraseToAnyPublisher()
    }

//    @Publisher var location2: CLLocation

    override public init() {
        super.init()
        manager.delegate = self
        #if os(iOS)
            manager.requestWhenInUseAuthorization()
        #endif
    }

    // MARK: -

    public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach {
            _location.send($0)
        }
    }

    public func locationManager(_: CLLocationManager, didFailWithError _: Error) {
        // unimplemented()
    }
}

public enum LatitudeLongitude: CaseIterable {
    case latitude
    case longitude
}

public enum Hemisphere: CaseIterable {
    case east
    case west
    case north
    case south
}

public func hemisphere(for degrees: CLLocationDegrees, latlon: LatitudeLongitude) -> Hemisphere {
    switch (degrees >= 0, latlon) {
    case (true, .latitude):
        return .north
    case (false, .latitude):
        return .south
    case (true, .longitude):
        return .east
    case (false, .longitude):
        return .west
    }
}

extension Hemisphere: CustomStringConvertible {
    public var description: String {
        switch self {
        case .north:
            return "n"
        case .south:
            return "s"
        case .east:
            return "e"
        case .west:
            return "w"
        }
    }
}

public extension CLLocationCoordinate2D {
    var components: [CLLocationDegrees] {
        [latitude, longitude]
    }
}

public class LocationCoordinate2DFormatter: Formatter {
    public struct Options: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let includeHemisphere = Options(rawValue: 1 << 0)
    }

    public var options: Options
    public var angleFormatter: AngleFormatter

    public init(options: Options = [.includeHemisphere], angleFormatter: AngleFormatter = AngleFormatter()) {
        self.options = options
        self.angleFormatter = angleFormatter
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func string(for obj: Any?) -> String? {
        guard let obj = obj else {
            return nil
        }

        switch obj {
        case let obj as CLLocation:
            return string(for: obj.coordinate)
        case let obj as CLLocationCoordinate2D:
            let includeHemisphere = options.contains(.includeHemisphere)
            let c = zip(LatitudeLongitude.allCases, obj.components)
            let components = c.map { latLon, degrees -> String in
                if includeHemisphere {
                    let s1 = angleFormatter.string(for: abs(degrees))!
                    let s2 = hemisphere(for: degrees, latlon: latLon).description.uppercased()
                    return s1 + " " + s2
                }
                else {
                    return angleFormatter.string(for: degrees)!
                }
            }
            return components.joined(separator: ", ")
        default:
            return nil
        }
    }
}

public class AngleFormatter: Formatter {
    //    sexagesimal degree: degrees, minutes, and seconds : 40° 26′ 46″ N 79° 58′ 56″ W
    //    degrees and decimal minutes: 40° 26.767′ N 79° 58.933′ W
    //    decimal degrees: 40.446° N 79.982° W

    public enum Format {
        case decimalDegree
        case degreeMinuteSecond
        case degreeDecimalMinute
    }

    public struct Options: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let showDegreeSymbol = Options(rawValue: 1 << 0)
    }

    public var format: Format
    public var options: Options
    public var decimalDegreeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 6
        return formatter
    }()

    public var decimalSecondsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    public init(format: Format = .degreeMinuteSecond, options: Options = [.showDegreeSymbol]) {
        self.format = format
        self.options = options
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func string(for obj: Any?) -> String? {
        guard let obj = obj else {
            return nil
        }

        switch obj {
        case let decimalDegrees as Double:
            switch format {
            case .decimalDegree:
                return decimalDegreeFormatter.string(for: decimalDegrees)! + (options.contains(.showDegreeSymbol) ? "°" : "")
            case .degreeMinuteSecond:
                let degrees = floor(decimalDegrees)
                let minutes = floor(60 * (decimalDegrees - degrees))
                let seconds = 3_600 * (decimalDegrees - degrees) - 60 * minutes
                return "\(Int(degrees))° \(Int(minutes))' \(decimalSecondsFormatter.string(for: seconds)!)\""
            default:
                unimplemented()
            }
        default:
            return nil
        }
    }
}
