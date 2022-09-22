#if os(iOS)
    import Combine
    import CoreMotion

    public class CoreMotionPublisher {
        public static let shared = CoreMotionPublisher()

        let manager: CMMotionManager
        let queue = OperationQueue()

        // TODO: This won't stop getting gyro events
        private let _gyro = PassthroughSubject<CMGyroData, Error>()

        public var gyro: AnyPublisher<CMGyroData, Error> {
            manager.startGyroUpdates(to: queue) { [weak self] data, error in
                guard let self = self else {
                    return
                }
                if let data {
                    self._gyro.send(data)
                }
                if let error {
                    self._gyro.send(completion: .failure(error))
                }
            }
            return _gyro.eraseToAnyPublisher()
        }

        public init() {
            manager = CMMotionManager()
        }
    }

#endif
