import Foundation
import Observation
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
#endif

@Observable
class SuperImportHelper {
    var identifier: String
    var url: URL?
    var recents: [URL] = []
    var bundledFiles: [URL] = []

    init(identifier: String, allowedContentTypes: [UTType]) {
        self.identifier = identifier
        self.url = storedURL()
        self.recents = loadRecents()
        self.bundledFiles = findBundledFiles(for: allowedContentTypes)
    }

    @discardableResult
    private func ensureCachesDirectory() throws -> URL {
        let cachesDirectory = try FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first.orThrow(GeneralError.generic("Could not resolve caches directory"))
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: cachesDirectory.path, isDirectory: &isDirectory)
        if !(exists && isDirectory.boolValue) {
            try FileManager.default.createDirectory(at: cachesDirectory, withIntermediateDirectories: true)
        }
        return cachesDirectory
    }

    func storedURL() -> URL? {
        do {
            let cachesDirectory = try ensureCachesDirectory()
            let identifierDirectory = cachesDirectory.appendingPathComponent(identifier)
            guard FileManager.default.fileExists(atPath: identifierDirectory.path) else {
                return nil
            }
            let contents = try? FileManager.default.contentsOfDirectory(at: identifierDirectory, includingPropertiesForKeys: nil)
            return contents?.first
        } catch {
            return nil
        }
    }

    func storeImportedFile(at url: URL, addToRecents shouldAddToRecents: Bool = true) throws {
        let hasAccess = url.startAccessingSecurityScopedResource()
        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        // Create bookmark immediately while we have access
        var bookmarkData: Data?
        #if os(macOS)
        if shouldAddToRecents {
            bookmarkData = try? url.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess])
        }
        #endif

        let cachesDirectory = try ensureCachesDirectory()
        let identifierDirectory = cachesDirectory.appendingPathComponent(identifier)

        // Remove existing identifier directory if it exists
        if FileManager.default.fileExists(atPath: identifierDirectory.path) {
            try FileManager.default.removeItem(at: identifierDirectory)
        }

        // Create identifier directory
        try FileManager.default.createDirectory(at: identifierDirectory, withIntermediateDirectories: true)

        // Copy file with original name
        let destinationURL = identifierDirectory.appendingPathComponent(url.lastPathComponent)
        try FileManager.default.copyItem(at: url, to: destinationURL)

        self.url = destinationURL

        // Add to recents with pre-created bookmark
        if shouldAddToRecents, let bookmarkData {
            addToRecents(url, bookmark: bookmarkData)
        }
    }

    private func loadRecents() -> [URL] {
        #if os(macOS)
        let key = "SuperImportHelper.recents.\(identifier)"
        guard let bookmarksData = UserDefaults.standard.array(forKey: key) as? [Data] else {
            return []
        }

        return bookmarksData.compactMap { bookmarkData -> URL? in
            var isStale = false
            guard let url = try? URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, bookmarkDataIsStale: &isStale), !isStale else {
                return nil
            }
            // Store the bookmark data for later use
            recentBookmarks[url] = bookmarkData
            return url
        }
        #else
        return []
        #endif
    }

    private func saveRecents() {
        let key = "SuperImportHelper.recents.\(identifier)"
        let bookmarks = recents.compactMap { url -> Data? in
            recentBookmarks[url]
        }
        UserDefaults.standard.set(bookmarks, forKey: key)
    }

    // Store bookmarks alongside URLs
    private var recentBookmarks: [URL: Data] = [:]

    private func addToRecents(_ url: URL, bookmark: Data) {
        recents.removeAll { $0.path == url.path }
        recents.insert(url, at: 0)
        recentBookmarks[url] = bookmark
        if recents.count > 10 {
            let removed = recents.removeLast()
            recentBookmarks.removeValue(forKey: removed)
        }
        saveRecents()
    }

    private func findBundledFiles(for allowedContentTypes: [UTType]) -> [URL] {
        guard let resourceURL = Bundle.main.resourceURL else {
            return []
        }

        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: resourceURL, includingPropertiesForKeys: [.contentTypeKey]) else {
            return []
        }

        var files: [URL] = []
        for case let url as URL in enumerator {
            guard let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey]), let contentType = resourceValues.contentType, allowedContentTypes.contains(where: { contentType.conforms(to: $0) }) else {
                continue
            }
            files.append(url)
        }
        return files.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    func reset() throws {
        let cachesDirectory = try ensureCachesDirectory()
        let identifierDirectory = cachesDirectory.appendingPathComponent(identifier)

        if FileManager.default.fileExists(atPath: identifierDirectory.path) {
            try FileManager.default.removeItem(at: identifierDirectory)
        }
        self.url = nil
    }

    #if os(macOS)
    func reveal() {
        guard let url = storedURL() else {
            return
        }
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    #endif
}
