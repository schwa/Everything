import SwiftUI

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

    init(systemImage systemName: String, action: @escaping () -> Void) where Label == Image {
        self = Button(action: action) {
            Image(systemName: systemName)
        }
    }
}
