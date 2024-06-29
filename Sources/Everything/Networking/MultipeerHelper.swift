import Combine
import Foundation
import MultipeerConnectivity

public class MultipeerHelper: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    public let serviceType: String
    public let peerID: MCPeerID
    public let session: MCSession
    public let requiredDiscoveryInfo = ["uniqueServiceType": "53A53E5F-2A42-4400-9D3B-9ED7865FEE00"]
    public let maximumPeerCount: Int? = 1
    public let publisher: AnyPublisher<Event, Never>
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    private var cancellables: Set<AnyCancellable> = []
    private var passthrough = PassthroughSubject<Event, Never>()

    public struct Event {
        public let peer: MCPeerID
        public enum Message: Equatable {
            case connecting
            case connected
            case notConnected
            case received(Data)
        }

        public let message: Message
    }

    public typealias Failure = Never

    @Published
    public var connectedPeers: [MCPeerID] = []

    @MainActor
    public required init(serviceType: String) {
        self.serviceType = serviceType

        #if os(macOS)
        peerID = MCPeerID(displayName: Host.current().localizedName!)
        #else
        peerID = MCPeerID(displayName: UIDevice.current.name)
        #endif

        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: requiredDiscoveryInfo, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        publisher = passthrough.eraseToAnyPublisher()
        super.init()
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    public func canPeerJoin(_ peerID: MCPeerID) -> Bool {
        let peers = session.connectedPeers.filter { $0 != peerID }
        if let maximumPeerCount, peers.count >= maximumPeerCount {
            print("## Too many peers")
            return false
        }
        return true
    }

    // MARK: -

    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
        switch state {
        case .connected:
            passthrough.send(.init(peer: peerID, message: .connected))

        case .connecting:
            passthrough.send(.init(peer: peerID, message: .connecting))

        case .notConnected:
            passthrough.send(.init(peer: peerID, message: .notConnected))

        default:
            break
        }
    }

    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        passthrough.send(.init(peer: peerID, message: .received(data)))
    }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("##", #function, stream, streamName, peerID)
    }

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("##", #function, resourceName, peerID, progress)
    }

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("##", #function, resourceName, peerID, localURL as Any, error as Any)
    }

    public func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }

    // MARK: -

    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        //        print("##", #function, error)
    }

    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(canPeerJoin(peerID), session)
    }

    // MARK: -

    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    }

    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        // TODO: check
        if info != requiredDiscoveryInfo {
            print("## Peer has wrong discovery info. Ignoring.")
            return
        }
        if canPeerJoin(peerID) == false {
            print("## Already have too many peers")
            return
        }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 5)
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    }
}

// MARK: -
