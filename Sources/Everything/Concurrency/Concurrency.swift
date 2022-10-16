import Foundation

public extension MainActor {
    static func runTask(_ block: @MainActor @Sendable @escaping () -> Void) {
        Task {
            await Self.run {
                block()
            }
        }
    }
}
