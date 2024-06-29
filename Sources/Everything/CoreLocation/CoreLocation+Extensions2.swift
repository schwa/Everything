import Combine
import CoreLocation

public extension CLGeocoder {
    static let shared = CLGeocoder()

    func geocodeAddressString(_ addressString: String) -> AnyPublisher<[CLPlacemark], Error> {
        Future<[CLPlacemark], Error> { future in
            self.geocodeAddressString(addressString) { placemarks, error in
                if let placemarks {
                    future(.success(placemarks))
                } else if let error {
                    future(.failure(error))
                } else {
                    unimplemented()
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func reverseGeocodeLocation(_ location: CLLocation) -> AnyPublisher<[CLPlacemark], Error> {
        Future<[CLPlacemark], Error> { future in
            self.reverseGeocodeLocation(location) { placemarks, error in
                if let placemarks {
                    future(.success(placemarks))
                } else if let error {
                    future(.failure(error))
                } else {
                    unimplemented()
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
