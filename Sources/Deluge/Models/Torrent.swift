import Foundation

/// A Deluge torrent.
public struct Torrent: Equatable, Decodable, Sendable {
    /// The date the torrent was added to the server.
    public var dateAdded: Date?
    /// The number of bytes downloaded for the torrent.
    public var downloaded: Int64?
    /// The file path where the torrent data is being downloaded to.
    public var downloadPath: String?
    /// The download rate for the torrent in bytes/s.
    public var downloadRate: Int64?
    /// The estimated number of seconds until the torrent completes downloading.
    public var eta: TimeInterval?
    /// The SHA1 hash for the torrent.
    public var hash: String
    /// The label assigned to the torrent. If no label is assigned then the value will be an empty string.
    public var label: String?
    /// The name of the torrent.
    public var name: String?
    /// The number of peers connected for the torrent.
    public var peers: Int?
    /// The download progress for the torrent as a percentage. This is a value between 0 and 1.
    public var progress: Float?
    /// The number of connected seeds for the torrent.
    public var seeds: Int?
    /// The size of the torrent contents in bytes.
    public var size: Int64?
    /// The state of the torrent.
    public var state: State?
    /// The number of available peers for the torrent.
    public var totalPeers: Int?
    /// The number of available seeds for the torrent.
    public var totalSeeds: Int?
    /// The trackers used by the torrent.
    public var trackers: [Tracker]?
    /// The number of bytes uploaded for the torrent.
    public var uploaded: Int64?
    /// The upload rate for the torrent in bytes/s.
    public var uploadRate: Int64?

    /// Initializes a torrent.
    public init(
        dateAdded: Date? = nil,
        downloaded: Int64? = nil,
        downloadPath: String? = nil,
        downloadRate: Int64? = nil,
        eta: TimeInterval? = nil,
        hash: String,
        label: String? = nil,
        name: String? = nil,
        peers: Int? = nil,
        progress: Float? = nil,
        seeds: Int? = nil,
        size: Int64? = nil,
        state: Torrent.State? = nil,
        totalPeers: Int? = nil,
        totalSeeds: Int? = nil,
        trackers: [Tracker]? = nil,
        uploaded: Int64? = nil,
        uploadRate: Int64? = nil
    ) {
        self.dateAdded = dateAdded
        self.downloaded = downloaded
        self.downloadPath = downloadPath
        self.downloadRate = downloadRate
        self.eta = eta
        self.hash = hash
        self.label = label
        self.name = name
        self.peers = peers
        self.progress = progress
        self.seeds = seeds
        self.size = size
        self.state = state
        self.totalPeers = totalPeers
        self.totalSeeds = totalSeeds
        self.trackers = trackers
        self.uploaded = uploaded
        self.uploadRate = uploadRate
    }
}

public extension Torrent {
    /// The state of a torrent.
    enum State: String, Equatable, Decodable, Sendable {
        /// The torrent is downloading.
        case downloading = "Downloading"
        /// The torrent is seeding.
        case seeding = "Seeding"
        /// The torrent is paused.
        case paused = "Paused"
        /// The torrent data is being verified.
        case checking = "Checking"
        /// The torrent is in the queue.
        case queued = "Queued"
        /// The torrent has an error.
        case error = "Error"
    }
}

public extension Torrent {
    /// The keys used to request torrent properties.
    enum PropertyKeys: String, CodingKey, CaseIterable {
        /// Requests the key `time_added` from the API.
        case dateAdded = "time_added"
        /// Requests the key `total_done` from the API.
        case downloaded = "total_done"
        /// Requests the key `download_location` from the API.
        case downloadPath = "download_location"
        /// Requests the key `download_payload_rate` from the API.
        case downloadRate = "download_payload_rate"
        /// Requests the key `eta` from the API.
        case eta
        /// Requests the key `label` from the API.
        case label
        /// Requests the key `name` from the API.
        case name
        /// Requests the key `num_peers` from the API.
        case peers = "num_peers"
        /// Requests the key `progress` from the API.
        case progress
        /// Requests the key `num_seeds` from the API.
        case seeds = "num_seeds"
        /// Requests the key `total_size` from the API.
        case size = "total_size"
        /// Requests the key `state` from the API.
        case state
        /// Requests the key `total_peers` from the API.
        case totalPeers = "total_peers"
        /// Requests the key `total_seeds` from the API.
        case totalSeeds = "total_seeds"
        /// Requests the key `trackers` from the API.
        case trackers
        /// Requests the key `total_uploaded` from the API.
        case uploaded = "total_uploaded"
        /// Requests the key `upload_payload_rate` from the API.
        case uploadRate = "upload_payload_rate"
    }
}

extension Torrent {
    private static func state(for value: String) -> State? {
        switch value {
        case "Downloading":
            return .downloading
        case "Seeding":
            return .seeding
        case "Paused":
            return .paused
        case "Checking":
            return .checking
        case "Queued":
            return .queued
        case "Error":
            return .error
        default:
            return nil
        }
    }

    /// Initializes a torrent using a response dictionary.
    /// - Parameters:
    ///   - hash: The torrent's hash.
    ///   - dictionary: The response dictionary for the torrent.
    init(hash: String, dictionary: [String: Any]) {
        func decode<Value>(_ propertyKey: PropertyKeys, _ type: Value.Type? = nil) -> Value? {
            dictionary[propertyKey.rawValue] as? Value
        }

        dateAdded = decode(.dateAdded).map(Date.init(timeIntervalSince1970:))
        downloaded = decode(.downloaded)
        downloadPath = decode(.downloadPath)
        downloadRate = decode(.downloadRate)
        eta = decode(.eta)
        self.hash = hash
        label = decode(.label)
        name = decode(.name)
        peers = decode(.peers)
        progress = decode(.progress).map { $0 / 100 }
        seeds = decode(.seeds)
        size = decode(.size)
        state = decode(.state).flatMap(Self.state)
        totalPeers = decode(.totalPeers)
        totalSeeds = decode(.totalSeeds)
        trackers = decode(.trackers, [[String: Any]].self).flatMap { $0.compactMap(Tracker.init) }
        uploaded = decode(.uploaded)
        uploadRate = decode(.uploadRate)
    }
}
