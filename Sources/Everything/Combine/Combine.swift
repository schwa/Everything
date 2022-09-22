import Combine
import Foundation

public extension Publisher where Failure == Never {
    // Block only gets the first output from
    func block() -> Output {
        let done = DispatchSemaphore(value: 0)
        var result: Output!
        let s = sink { output in
            result = output
            done.signal()
        }
        done.wait()
        s.cancel()
        return result
    }
}

public extension Publisher {
    func block() throws -> Output {
        let done = DispatchSemaphore(value: 0)
        var result: Result<Output, Failure>?
        let s = sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                result = .failure(error)
            default:
                unimplemented()
            }
            done.signal()
        }, receiveValue: { output in
            result = .success(output)
            done.signal()
        })
        done.wait()
        s.cancel()
        return try result!.get()
    }
}
