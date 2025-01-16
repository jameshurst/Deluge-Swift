import APIClient
import Foundation

public extension Request {
    /// Requests the information required to update the web interface.
    ///
    /// RPC Method: `web.update_ui`
    ///
    /// Result: A tuple containing the list of torrents and labels.
    ///
    /// - Parameter properties: The torrent properties to include.
    static func updateUI(properties: [Torrent.PropertyKeys]) -> Request<TorrentsAndLabels> {
        .init(method: "web.update_ui", args: [properties.map(\.rawValue), []])
    }

    /// Requests the list of items for a torrent.
    ///
    /// RPC Method: `web.get_torrent_files`
    ///
    /// Result: The list items for the torrent.
    ///
    /// - Parameter hash: The hash of the torrent whose items should be requested.
    static func torrentItems(hash: String) -> Request<[TorrentItem]> {
        .init(method: "web.get_torrent_files", args: [hash]) { data in
            let response = try JSONDecoder().decode(Deluge.Response<TorrentTree>.self, from: data)
            return response.result.toItems()
        }
    }

    /// Requests the connection status of the Deluge daemon.
    ///
    /// RPC Method: `web.connected`
    ///
    /// Result: A boolean indicating whether the Deluge daemon is currently connected.
    static var connected: Request<Bool> {
        .init(method: "web.connected", args: [])
    }

    /// Requests the list of hosts.
    ///
    /// RPC Method: `web.get_hosts`
    ///
    /// Result: The list of hosts.
    static var hosts: Request<[Host]> {
        .init(method: "web.get_hosts", args: [])
    }

    /// Connects to a given host.
    ///
    /// RPC Method: `web.connect`
    ///
    /// - Parameter hostID: The ID of the host to connect to.
    static func connect(to hostID: Host.ID) -> Request<EmptyResponse> {
        .init(method: "web.connect", args: [hostID])
    }

    /// All avaliable and enables plugins in the web UI
    ///
    /// RPC Method: `web.get_plugins`
    static var plugins: Request<Plugins> {
        .init(method: "web.get_plugins", args: [])
    }
}
