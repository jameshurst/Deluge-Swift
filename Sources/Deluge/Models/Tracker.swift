/// A Deluge torrent tracker.
public struct Tracker: Equatable, Decodable, Sendable {
    /// The tracker URL.
    public var url: String

    /// Initializes a tracker.
    public init(url: String) {
        self.url = url
    }
}
