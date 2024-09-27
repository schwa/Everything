import Combine
import CoreMedia
import CoreVideo
import QuartzCore
import SwiftUI

public struct DisplayLinkEvent<Time>: Sendable where Time: Sendable {
    public let currentTime: Time
    public let displayTime: Time
    public let duration: Time?
    public let frameCount: Int
    public let firstDisplayTime: Time
    public let lastDisplayTime: Time?
}

public struct DisplayLinkTiming<Time>: Sendable where Time: Sendable {
    var frameCount: Int = 0
    var lastDisplayTime: Time?
    var firstDisplayTime: Time?

    mutating func tick(currentTime: Time, displayTime: Time, duration: Time? = nil) -> DisplayLinkEvent<Time> {
        frameCount += 1
        if firstDisplayTime == nil {
            firstDisplayTime = displayTime
        }
        defer {
            lastDisplayTime = displayTime
        }
        return DisplayLinkEvent(currentTime: currentTime, displayTime: displayTime, duration: duration, frameCount: frameCount, firstDisplayTime: firstDisplayTime!, lastDisplayTime: lastDisplayTime)
    }
}

#if os(macOS)
public final class DisplayLinkPublisherClassic: Publisher, @unchecked Sendable {
    public typealias Output = DisplayLinkEvent<CMTime>
    public typealias Failure = Never
    private var displayLink: CVDisplayLink!

    private var timing = DisplayLinkTiming<CMTime>()
    private var passthrough = PassthroughSubject<Output, Failure>()

    public init() {
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)

        func _callback(displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
            let displayLinkPublisher = Unmanaged<DisplayLinkPublisherClassic>.fromOpaque(displayLinkContext!).takeUnretainedValue()
            displayLinkPublisher.tick(currentTime: inNow.pointee, displayTime: inOutputTime.pointee)
            return 0
        }


        CVDisplayLinkSetOutputCallback(displayLink!, _callback, Unmanaged.passUnretained(self).toOpaque())
    }

    deinit {
        guard let displayLink else {
            return
        }
        CVDisplayLinkStop(displayLink)
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        CVDisplayLinkStart(displayLink)
        passthrough.receive(subscriber: subscriber)
    }

    internal func tick(currentTime: CVTimeStamp, displayTime: CVTimeStamp) {
        let currentTime = CMTimeMake(value: currentTime.videoTime, timescale: currentTime.videoTimeScale)
        let displayTime = CMTimeMake(value: displayTime.videoTime, timescale: displayTime.videoTimeScale)

        var duration: CMTime?
        if let lastDisplayTime = timing.lastDisplayTime {
            let range = CMTimeRange(start: lastDisplayTime, end: displayTime)
            duration = range.duration
        }

        passthrough.send(timing.tick(currentTime: currentTime, displayTime: displayTime, duration: duration))
    }
}
#endif

@available(macOS 14, iOS 15, tvOS 16, *)
public class DisplayLinkPublisher: Publisher {
    public typealias Output = DisplayLinkEvent<CFTimeInterval>
    public typealias Failure = Never

    private var timing = DisplayLinkTiming<CFTimeInterval>()
    private var passthrough = PassthroughSubject<Output, Failure>()
    private var displayLink: CADisplayLink!

    public init() {
        #if os(macOS)
        // TODO: for now - use main screen displaylink
        guard let screen = NSScreen.main ?? NSScreen.screens.first else {
            fatalError("No screen")
        }
        displayLink = screen.displayLink(target: self, selector: #selector(Self.tick))
        #else
        displayLink = CADisplayLink(target: self, selector: #selector(Self.tick))
        #endif
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        passthrough.receive(subscriber: subscriber)
    }

    @objc
    private func tick(_ displayLink: CADisplayLink) {
        let event = timing.tick(currentTime: displayLink.timestamp, displayTime: displayLink.targetTimestamp, duration: displayLink.duration)
        passthrough.send(event)
    }
}

public extension CMTime {
    var seconds: TimeInterval {
        CMTimeGetSeconds(self)
    }
}

public extension CFTimeInterval {
    var seconds: TimeInterval {
        self
    }
}

// DisplayLink
@available(macOS 14, iOS 15, tvOS 16, *)
public struct DisplayLink {
    // TODO: Get rid of publisher and just use a Async* api directly.

    public let displayLinkPublisher: DisplayLinkPublisher

    public init() {
        displayLinkPublisher = DisplayLinkPublisher()
    }

    public func events() -> AsyncPublisher<DisplayLinkPublisher> {
        displayLinkPublisher.values
    }
}

// MARK: -

@available(macOS 14, iOS 15, tvOS 16, *)
public struct DisplayLinkKey: EnvironmentKey, Sendable {
    // TODO: FIXME
    nonisolated(unsafe) public static let defaultValue: DisplayLink? = nil
}

@available(macOS 14, iOS 15, tvOS 16, *)
public extension EnvironmentValues {
    var displayLink: DisplayLink? {
        get {
            self[DisplayLinkKey.self]
        }
        set {
            self[DisplayLinkKey.self] = newValue
        }
    }
}

@available(macOS 14, iOS 15, tvOS 16, *)
public extension View {
    func displayLink(_ displayLink: DisplayLink) -> some View {
        environment(\.displayLink, displayLink)
    }
}
