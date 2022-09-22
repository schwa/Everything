import SwiftUI

public struct ErrorHandler {
    var callback: (Error) -> Void

    public func handle(error: Error) {
        callback(error)
    }

    public func handle(_ block: () throws -> Void) {
        do {
            try block()
        }
        catch {
            handle(error: error)
        }
    }

    public func handle<R>(_ block: () throws -> R) -> R? {
        do {
            return try block()
        }
        catch {
            handle(error: error)
            return nil
        }
    }
}

public struct ErrorHandlerKey: EnvironmentKey {
    public static var defaultValue = ErrorHandler {
        fatalError("Unhandled error: \($0)")
    }
}

public extension EnvironmentValues {
    var errorHandler: ErrorHandler {
        get {
            self[ErrorHandlerKey.self]
        }
        set {
            self[ErrorHandlerKey.self] = newValue
        }
    }
}

public struct ErrorHandlingView<Content>: View where Content: View {
    let content: () -> Content

    @State
    var error: Error?
    @State
    var isPresented = false

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content().environment(\.errorHandler, ErrorHandler {
            self.error = $0
            self.isPresented = true
        })
        .alert(isPresented: $isPresented) {
            guard let error = error else {
                fatalError("Ironically our error handler had an error.")
            }
            return Alert(title: Text("Error"), message: Text("\(String(describing: error))"), dismissButton: .default(Text("That sucks")))
        }
    }
}

public extension View {
    func errorHostView() -> some View {
        ErrorHandlingView {
            self
        }
    }
}
