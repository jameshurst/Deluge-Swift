public extension Request {
    /// Sets the label for a torrent.
    ///
    /// RPC Method: `label.set_torrent`
    ///
    /// - Parameters:
    ///   - hash: The hash of the torrent whose label should be set.
    ///   - label: The name of the label to set.
    static func setLabel(hash: String, label: String) -> Request<Void> {
        .init(method: "label.set_torrent", args: [hash, label])
    }
}
