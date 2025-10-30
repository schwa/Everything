import SwiftUI
import UniformTypeIdentifiers

public struct SuperImportWell <Content>: View where Content: View {
    var allowedContentTypes: [UTType]
    var content: (URL) -> Content

    @Binding
    private var url: URL?

    @State
    private var helper: SuperImportHelper

    public init(url: Binding<URL?>, identifier: String, allowedContentTypes: [UTType], content: @escaping (URL) -> Content) {
        self._url = url
        self.allowedContentTypes = allowedContentTypes
        self.content = content
        self._helper = State(initialValue: SuperImportHelper(identifier: identifier, allowedContentTypes: allowedContentTypes))
    }

    public var body: some View {
        Group {
            if let url = helper.url {
                content(url)
            }
            else {
                ContentUnavailableView("No File", systemImage: "exclamationmark.triangle")
            }
        }
        .onChange(of: helper.url, initial: true) {
            url = helper.url
        }
    }
}
