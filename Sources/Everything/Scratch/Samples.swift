import Combine
import SwiftUI

private var cancellables: Set<AnyCancellable> = []

public class Samples: ObservableObject {
    @Published
    public var samples: [String: Sample] = [:]

    public struct Sample {
        public let key: String
        public let value: Any
    }

    public init() {
    }

    public func post(key: String, value: Any) {
        let sample = Sample(key: key, value: value)
        samples[key] = sample
    }
}

// MARK: -

public struct SamplesKey: EnvironmentKey {
    public static var defaultValue = Samples()
}

public extension EnvironmentValues {
    var samples: Samples {
        get {
            self[SamplesKey.self]
        }
        set {
            self[SamplesKey.self] = newValue
        }
    }
}

// MARK: -

public struct SamplesView: View {
    @ObservedObject
    public var samples: Samples

    public init(samples: Samples? = nil) {
        self.samples = samples ?? Samples()
    }

    public var body: some View {
        let keys = Array(samples.samples.keys).sorted()
        return VStack {
            List(keys, id: \.self, rowContent: self.row)
            Button("Post") {
                self.samples.post(key: "Key", value: 1)
            }
        }
    }

    func row(for key: Dictionary<String, Samples.Sample>.Key) -> some View {
        let sample = samples.samples[key]!
        return HStack {
            Text(sample.key)
            Text(String(describing: sample.value))
        }
    }
}
