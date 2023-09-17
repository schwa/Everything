import Combine
import CoreLocation
import Foundation

public class CoreLocationManager: NSObject, CLLocationManagerDelegate {
    public static let shared = CoreLocationManager()

    public let manager = CLLocationManager()

    private let _location = PassthroughSubject<CLLocation, Error>()
    public var location: AnyPublisher<CLLocation, Error> {
        #if !os(tvOS)
        manager.startUpdatingLocation()
        #endif
        return _location.eraseToAnyPublisher()
    }

//    @Publisher var location2: CLLocation

    override public init() {
        super.init()
        manager.delegate = self
        #if os(iOS) || os(tvOS)
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
