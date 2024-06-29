#if os(macOS)

import Combine
import Foundation

public class FSEventPublisher: Publisher {
    public struct Event {
        public struct Flags: OptionSet, CustomStringConvertible {
            public let rawValue: Int

            public static let mustScanSubDirs = Self(rawValue: kFSEventStreamEventFlagMustScanSubDirs)
            public static let userDropped = Self(rawValue: kFSEventStreamEventFlagUserDropped)
            public static let kernelDropped = Self(rawValue: kFSEventStreamEventFlagKernelDropped)
            public static let eventIdsWrapped = Self(rawValue: kFSEventStreamEventFlagEventIdsWrapped)
            public static let historyDone = Self(rawValue: kFSEventStreamEventFlagHistoryDone)
            public static let rootChanged = Self(rawValue: kFSEventStreamEventFlagRootChanged)
            public static let mount = Self(rawValue: kFSEventStreamEventFlagMount)
            public static let unmount = Self(rawValue: kFSEventStreamEventFlagUnmount)
            public static let itemCreated = Self(rawValue: kFSEventStreamEventFlagItemCreated)
            public static let itemRemoved = Self(rawValue: kFSEventStreamEventFlagItemRemoved)
            public static let itemInodeMetaMod = Self(rawValue: kFSEventStreamEventFlagItemInodeMetaMod)
            public static let itemRenamed = Self(rawValue: kFSEventStreamEventFlagItemRenamed)
            public static let itemModified = Self(rawValue: kFSEventStreamEventFlagItemModified)
            public static let itemFinderInfoMod = Self(rawValue: kFSEventStreamEventFlagItemFinderInfoMod)
            public static let itemChangeOwner = Self(rawValue: kFSEventStreamEventFlagItemChangeOwner)
            public static let itemXattrMod = Self(rawValue: kFSEventStreamEventFlagItemXattrMod)
            public static let itemIsFile = Self(rawValue: kFSEventStreamEventFlagItemIsFile)
            public static let itemIsDir = Self(rawValue: kFSEventStreamEventFlagItemIsDir)
            public static let itemIsSymlink = Self(rawValue: kFSEventStreamEventFlagItemIsSymlink)
            public static let ownEvent = Self(rawValue: kFSEventStreamEventFlagOwnEvent)
            public static let itemIsHardlink = Self(rawValue: kFSEventStreamEventFlagItemIsHardlink)
            public static let itemIsLastHardlink = Self(rawValue: kFSEventStreamEventFlagItemIsLastHardlink)
            public static let itemCloned = Self(rawValue: kFSEventStreamEventFlagItemCloned)

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }

            public var description: String {
                let cases: [(Self, String)] = [
                    (.mustScanSubDirs, "mustScanSubDirs"),
                    (.userDropped, "userDropped"),
                    (.kernelDropped, "kernelDropped"),
                    (.eventIdsWrapped, "eventIdsWrapped"),
                    (.historyDone, "historyDone"),
                    (.rootChanged, "rootChanged"),
                    (.mount, "mount"),
                    (.unmount, "unmount"),
                    (.itemCreated, "itemCreated"),
                    (.itemRemoved, "itemRemoved"),
                    (.itemInodeMetaMod, "itemInodeMetaMod"),
                    (.itemRenamed, "itemRenamed"),
                    (.itemModified, "itemModified"),
                    (.itemFinderInfoMod, "itemFinderInfoMod"),
                    (.itemChangeOwner, "itemChangeOwner"),
                    (.itemXattrMod, "itemXattrMod"),
                    (.itemIsFile, "itemIsFile"),
                    (.itemIsDir, "itemIsDir"),
                    (.itemIsSymlink, "itemIsSymlink"),
                    (.ownEvent, "ownEvent"),
                    (.itemIsHardlink, "itemIsHardlink"),
                    (.itemIsLastHardlink, "itemIsLastHardlink"),
                    (.itemCloned, "itemCloned")
                ]
                return cases.filter { contains($0.0) }.map(\.1).joined(separator: ", ")
            }
        }

        public let flags: Flags
        public let path: String
        public let eventID: FSEventStreamEventId
        public let fileID: UInt64?
    }

    public typealias Output = [Event]
    public typealias Failure = Never
    typealias Subscription = ConcreteSubscription<Output, Failure>

    public let latency: TimeInterval
    public let queue: DispatchQueue
    var stream: FSEventStreamRef!
    var subscriptions: Set<Subscription> = []

    public struct Options: OptionSet {
        public let rawValue: Int
        public static let noDefer = Self(rawValue: kFSEventStreamCreateFlagNoDefer)
        public static let watchRoot = Self(rawValue: kFSEventStreamCreateFlagWatchRoot)
        public static let ignoreSelf = Self(rawValue: kFSEventStreamCreateFlagIgnoreSelf)
        public static let fileEvents = Self(rawValue: kFSEventStreamCreateFlagFileEvents)
        public static let markSelf = Self(rawValue: kFSEventStreamCreateFlagMarkSelf)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    // swiftlint:disable:next line_length
    public init(paths: [String], latency: TimeInterval = 1, queue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default), options: Options = [], lastEventID: FSEventStreamEventId = UInt64(kFSEventStreamEventIdSinceNow)) throws {
        self.latency = latency
        self.queue = queue

        var context = FSEventStreamContext()
        context.info = Unmanaged.passUnretained(self).toOpaque() // TODO: balance retain release
        let paths = paths as CFArray
        let flags = kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagUseExtendedData | options.rawValue

        stream = FSEventStreamCreate(kCFAllocatorDefault, _callback, &context, paths, lastEventID, latency, FSEventStreamCreateFlags(flags))

        FSEventStreamSetDispatchQueue(stream, queue)
        FSEventStreamStart(stream)
    }

    deinit {
        FSEventStreamStop(stream)
        FSEventStreamRelease(stream)
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Subscription(subscriber: subscriber, request: { _, _ in }, cancel: { [weak self] subscription in
            self?.subscriptions.remove(subscription)
        })
        subscriptions.insert(subscription)
        subscriber.receive(subscription: subscription)
    }

    func send(_ event: Output) {
        subscriptions.forEach {
            let demand = $0.subscriber.receive(event)
            assert(demand.max == 0 || demand.max == nil)
        }
    }

    func send(completion: Subscribers.Completion<Failure>) {
        subscriptions.forEach {
            $0.subscriber.receive(completion: completion)
        }
    }
}

// swiftlint:disable:next function_parameter_count line_length
private func _callback(stream: ConstFSEventStreamRef, callbackInfo: UnsafeMutableRawPointer?, numEvents: Int, eventPaths: UnsafeMutableRawPointer, eventFlags: UnsafePointer<FSEventStreamEventFlags>, eventIds: UnsafePointer<FSEventStreamEventId>) {
    guard let callbackInfo else {
        return
    }
    let publisher = Unmanaged<FSEventPublisher>.fromOpaque(callbackInfo).takeUnretainedValue()
    let eventDictionaries = unsafeBitCast(eventPaths, to: NSArray.self) as! [NSDictionary]

    let events = eventDictionaries.enumerated().map { arg -> FSEventPublisher.Event in
        let (index, dictionary) = arg
        let flags = eventFlags[index]
        let eventID = eventIds[index]
        let path = dictionary[kFSEventStreamEventExtendedDataPathKey] as! String
        let fileID = dictionary[kFSEventStreamEventExtendedFileIDKey] as? UInt64
        return FSEventPublisher.Event(flags: .init(rawValue: Int(flags)), path: path, eventID: eventID, fileID: fileID)
    }
    publisher.send(events)
}

#endif // os(macOS)
