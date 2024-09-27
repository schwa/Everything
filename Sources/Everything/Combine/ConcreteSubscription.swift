import Combine

public struct ConcreteSubscription<Output, Failure>: Subscription, Hashable where Failure: Error {
    public let combineIdentifier: CombineIdentifier
    public let subscriber: AnySubscriber<Output, Failure>
    let _request: ((Self, Subscribers.Demand) -> Void)?
    let _cancel: ((Self) -> Void)?

    public init<S>(subscriber: S, request: @escaping (Self, Subscribers.Demand) -> Void, cancel: @escaping (Self) -> Void) where S: Subscriber, S.Input == Output, S.Failure == Failure {
        let subscriber = AnySubscriber(subscriber)
        combineIdentifier = subscriber.combineIdentifier
        self.subscriber = subscriber
        _request = request
        _cancel = cancel
    }

    public func request(_ demand: Subscribers.Demand) {
        _request?(self, demand)
    }

    public func cancel() {
        _cancel?(self)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.combineIdentifier == rhs.combineIdentifier
    }

    public func hash(into hasher: inout Hasher) {
        combineIdentifier.hash(into: &hasher)
    }
}
