import SwiftUI

// Button+Label conveniences
public extension Button {
    init(title: LocalizedStringKey, image: String, action: @escaping () -> Void)  where Label == SwiftUI.Label<Text, Image> {
        self = Button(action: action) {
            Label(title, image: image)
        }
    }
    
    init(title: LocalizedStringKey, systemImage: String, action: @escaping () -> Void) where Label == SwiftUI.Label<Text, Image> {
        self = Button(action: action) {
            Label(title, systemImage: systemImage)
        }
    }
}

// SF Symbol conveniences
public extension Button {
    init(systemImage systemName: String, action: @escaping () -> Void) where Label == Image {
        self = Button(action: action) {
            Image(systemName: systemName)
        }
    }
    
    init(title: String, systemImage systemName: String, action: @escaping @Sendable () async -> Void) where Label == SwiftUI.Label<Text, Image> {
        self = Button(action: {
            Task {
                await action()
            }
        }, label: {
            SwiftUI.Label(title, systemImage: systemName)
        })
    }
}

// Async extensions
public extension Button {
    init(_ title: String, action: @escaping @Sendable () async -> Void) where Label == Text {
        self = Button(title) {
            Task {
                await action()
            }
        }
    }

    init(systemImage systemName: String, action: @escaping @Sendable () async -> Void) where Label == Image {
        self = Button(action: {
            Task {
                await action()
            }
        }, label: {
            Image(systemName: systemName)
        })
    }

    init(action: @Sendable @escaping () async -> Void, @ViewBuilder label: () -> Label) {
        self = Button(action: {
            Task {
                await action()
            }
        }, label: {
            label()
        })
    }
}
