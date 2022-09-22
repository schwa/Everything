import Combine
import Foundation

public struct FileBookmark {
    class State {
        var bookmarkData: Data?
    }

    public let url: URL
    let creationOptions: URL.BookmarkCreationOptions
    let resolutionOptions: URL.BookmarkResolutionOptions
    let state = State()

    public init(url: URL, creationOptions: URL.BookmarkCreationOptions = [], resolutionOptions: URL.BookmarkResolutionOptions = []) throws {
        self.url = url
        self.creationOptions = creationOptions
        self.resolutionOptions = resolutionOptions
        if FileManager().fileExists(atPath: url.path) {
            state.bookmarkData = try url.bookmarkData(options: creationOptions, includingResourceValuesForKeys: nil, relativeTo: nil)
        }
    }

    public func resolve() throws -> URL? {
        guard let bookmarkData = state.bookmarkData else {
            return nil
        }
        var bookmarkDataIsStale = false
        let url = tryElseLog {
            try URL(resolvingBookmarkData: bookmarkData, options: resolutionOptions, relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale)
        }
        if let url, bookmarkDataIsStale {
            state.bookmarkData = try url.bookmarkData(options: creationOptions, includingResourceValuesForKeys: nil, relativeTo: nil)
        }
        return url
    }
}

#if os(macOS)
    public class AutoresolvingFileBookmark {
        @Published
        public private(set) var url: URL

        var bookmark: FileBookmark {
            didSet {
                url = bookmark.url
            }
        }

        let creationOptions: URL.BookmarkCreationOptions
        let resolutionOptions: URL.BookmarkResolutionOptions

        var publisher: FSEventPublisher?
        var cancellable: AnyCancellable?

        public init(url: URL, creationOptions: URL.BookmarkCreationOptions = [], resolutionOptions: URL.BookmarkResolutionOptions = []) throws {
            self.url = url
            bookmark = try FileBookmark(url: url, creationOptions: creationOptions, resolutionOptions: resolutionOptions)
            self.creationOptions = creationOptions
            self.resolutionOptions = resolutionOptions
        }

        func monitor() throws {
            cancellable?.cancel()
            let publisher = try FSEventPublisher(paths: [bookmark.url.path], options: [.noDefer, .fileEvents, .watchRoot])
            self.publisher = publisher
            cancellable = publisher.sink { _ in
                forceTry {
                    try self.changed()
                }
            }
        }

        func changed() throws {
            guard let newURL = try bookmark.resolve() else {
                return
            }
            bookmark = try FileBookmark(url: newURL, creationOptions: creationOptions, resolutionOptions: resolutionOptions)
            try monitor()
        }
    }

    // MARK: -

    public class FileBookmarkFollower {
        let bookmark: FileBookmark

        @Published
        public var currentURL: URL {
            didSet {
                forceTry {
                    try monitor()
                }
            }
        }

        var publisher: FSEventPublisher?
        var cancellable: AnyCancellable?

        public init(url: URL) throws {
            bookmark = try FileBookmark(url: url)
            let resolvedURL = try bookmark.resolve()
            currentURL = resolvedURL ?? url
            try monitor()
        }

        func monitor() throws {
            cancellable?.cancel()
            let publisher = try FSEventPublisher(paths: [currentURL.path], options: [.noDefer, .fileEvents, .watchRoot])
            self.publisher = publisher
            cancellable = publisher.sink { _ in
                forceTry {
                    self.currentURL = try self.bookmark.resolve() ?? self.currentURL
                }
            }
        }
    }
#endif
