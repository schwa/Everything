import SwiftUI

/**
 How to use:
 Somewhere (closer to the root) in your app call .errorHost() - this view will be the place where error dialogs are presented.
 Then deeper in your code do this to automatically catch and handle errors

 struct MyView: View {
     @Environment(\.errorHandler)
     var errorHandler

     var body: some View {
         Button("Maybe Fail") {
             errorHandler {
                 throw MyError.oops
             }
         }
     }
 }
 */
public struct ErrorHandler: Sendable {
    let callback: @Sendable (Error) -> Void

    public func handle(error: Error) {
        callback(error)
    }

    public func callAsFunction<R>(_ block: @Sendable () throws -> R?) -> R? where R: Sendable {
        do {
            return try block()
        }
        catch {
            handle(error: error)
            return nil
        }
    }

    public func callAsFunction<R>(_ block: @Sendable () async throws -> R?) async -> R? where R: Sendable {
        do {
            return try await block()
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

// TODO: This should become a ViewModifier and the actual error handler needs to become customisable.
public struct ErrorHandlingModifier: ViewModifier {
    @State
    var error: Error?
    @State
    var isPresented = false

    public func body(content: Content) -> some View {
        content.environment(\.errorHandler, ErrorHandler {
            self.error = $0
            self.isPresented = true
        })
        .alert(isPresented: $isPresented) {
            guard let error else {
                fatalError("Ironically our error handler had an error.")
            }
            return Alert(title: Text("Error"), message: Text("\(String(describing: error))"), dismissButton: .default(Text("That sucks")))
        }
    }
}

public extension View {
    func errorHost() -> some View {
        modifier(ErrorHandlingModifier())
    }
}
