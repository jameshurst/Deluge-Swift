/// A Deluge torrent tracker.
public struct Tracker: Equatable, Sendable {
    /// The tracker URL.
    public var url: String

    /// Initializes a tracker.
    public init(url: String) {
        self.url = url
    }
}

extension Tracker {
    /// Initializes a tracker using a response dictionary, returning nil if any required properties are missing.
    /// - Parameters:
    ///   - dictionary: The response dictionary for the tracker.
    init?(dictionary: [String: Any]) {
        guard let url = dictionary["url"] as? String else { return nil }
        self.url = url
    }
}
