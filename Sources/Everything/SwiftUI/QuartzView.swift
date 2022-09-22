import Combine
import SwiftUI

#if os(macOS)
    import AppKit

    public typealias QuartzViewRepresentable = NSViewRepresentable
    public typealias QuartzPlatformView = NSView
#elseif os(iOS)
    import UIKit

    public typealias QuartzViewRepresentable = UIViewRepresentable
    public typealias QuartzPlatformView = UIView
#endif

@available(*, deprecated, message: "Use Canvas or similar. Too many Swift Concurrency issues here.")
public struct QuartzView: QuartzViewRepresentable {
    public struct Options: OptionSet, Sendable {
        public let rawValue: Int
        public static let clear = Options(rawValue: 2 << 0)
        public static let center = Options(rawValue: 3 << 0)
        public static let drawAxes = Options(rawValue: 4 << 0)
        public static let redrawEveryFrame = Options(rawValue: 4 << 0)
        public static let `default`: Options = [.clear]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    public struct Parameter: @unchecked Sendable {
        public let bounds: CGRect
        public let context: CGContext
        public let dirtyRect: CGRect
    }

    public class Coordinator {
        var view: _View?
        let displayLink = DisplayLinkPublisher()
        var cancellables: Set<AnyCancellable> = []
    }

    let didMakeCoordinator: (Coordinator) -> Void
    let didMakeView: (_View) -> Void

    public init(options: Options = .default, draw: @escaping (Parameter) -> Void) {
        didMakeCoordinator = { coordinator in
            if options.contains(.redrawEveryFrame) {
                coordinator.displayLink
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    guard let view = coordinator.view else {
                        return
                    }
                    Task {
                        await MainActor.run {
                            #if os(macOS)
                                view.needsDisplay = true
                            #else
                                view.setNeedsDisplay()
                            #endif
                        }
                    }
                }
                .store(in: &coordinator.cancellables)
            }
        }
        didMakeView = { view in
            Task {
                await MainActor.run {
                    view.options = options
                    view.draw = draw
                }
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        didMakeCoordinator(coordinator)
        return coordinator
    }

    #if os(macOS)
        public func makeNSView(context: Context) -> _View {
            let view = _View()
            didMakeView(view)
            context.coordinator.view = view
            return view
        }

        public func updateNSView(_ view: _View, context: Context) {
            view.needsDisplay = true
        }

    #else
        public func makeUIView(context: Context) -> _View {
            let view = _View()
            didMakeView(view)
            context.coordinator.view = view
            return view
        }

        public func updateUIView(_ view: _View, context: Context) {
            #if os(macOS)
                view.needsDisplay = true
            #else
                view.setNeedsDisplay()
            #endif
        }
    #endif

    // swiftlint:disable:next type_name
    public class _View: QuartzPlatformView {
        var draw: ((Parameter) -> Void)?

        var options: Options = .default

        override public func draw(_ dirtyRect: CGRect) {
            #if os(macOS)
                guard let context = NSGraphicsContext.current?.cgContext, let draw = draw else {
                    return
                }
            #else
                guard let context = UIGraphicsGetCurrentContext(), let draw = draw else {
                    return
                }
            #endif
            if options.contains(.clear) {
                context.saveGState()
                context.setFillColor(CGColor.white)
                context.fill(dirtyRect)
                context.restoreGState()
            }

            if options.contains(.center) {
                context.translateBy(x: bounds.midX, y: bounds.midY)
            }

            if options.contains(.drawAxes) {
                context.saveGState()
                context.setLineWidth(0.5)
                context.addLines(between: [CGPoint(-1_000, 0), CGPoint(1_000, 0)])
                context.strokePath()
                context.addLines(between: [CGPoint(0, -1_000), CGPoint(0, 1_000)])
                context.strokePath()
                context.restoreGState()
            }

            // TODO: if center is false dirty rect is wrong!!!
            draw(Parameter(bounds: bounds, context: context, dirtyRect: dirtyRect))
        }
    }
}
