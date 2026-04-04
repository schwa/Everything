import SwiftUI
import UniformTypeIdentifiers

public struct SuperImportWidget: View {
    @Binding
    private var url: URL?

    var allowedContentTypes: [UTType]

    @State
    private var helper: SuperImportHelper

    @State
    private var isImporting = false

    public init(url: Binding<URL?>, identifier: String, allowedContentTypes: [UTType]) {
        self._url = url
        self.allowedContentTypes = allowedContentTypes
        self._helper = State(initialValue: SuperImportHelper(identifier: identifier, allowedContentTypes: allowedContentTypes))
    }

    public var body: some View {
        // swiftlint:disable:next closure_body_length
        Menu("Import") {
            Button("Choose…") {
                isImporting = true
            }

            Button("Reset") {
                resetCache()
            }
            .disabled(helper.url == nil)

            #if os(macOS)
            Button("Reveal") {
                revealInFinder()
            }
            .disabled(helper.url == nil)
            #endif

            if !helper.recents.isEmpty {
                Section("Recents") {
                    ForEach(helper.recents, id: \.self) { url in
                        Button(url.lastPathComponent) {
                            loadRecent(url)
                        }
                    }
                }
            }

            if !helper.bundledFiles.isEmpty {
                Section("Bundled") {
                    ForEach(helper.bundledFiles, id: \.self) { url in
                        Button(url.lastPathComponent) {
                            loadBundled(url)
                        }
                    }
                }
            }
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: allowedContentTypes) { result in
            if case .success(let url) = result {
                do {
                    try helper.storeImportedFile(at: url)
                }
                catch {
                    fatalError("Failed to store imported file: \(error)")
                }
            }
        }
        .onChange(of: helper.url, initial: true) {
            url = helper.url
        }
    }

    private func resetCache() {
        do {
            try helper.reset()
        }
        catch {
            fatalError("Failed to reset cached file: \(error)")
        }
    }

    private func loadRecent(_ url: URL) {
        do {
            try helper.storeImportedFile(at: url, addToRecents: false)
        }
        catch {
            fatalError("Failed to load recent file: \(error)")
        }
    }

    private func loadBundled(_ url: URL) {
        do {
            try helper.storeImportedFile(at: url, addToRecents: true)
        }
        catch {
            fatalError("Failed to load bundled file: \(error)")
        }
    }

    #if os(macOS)
    private func revealInFinder() {
        helper.reveal()
    }
    #endif
}
