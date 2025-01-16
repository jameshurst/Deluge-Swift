import Foundation

public struct TorrentsAndLabels: Decodable, Sendable {
    public let torrents: [Torrent]
    public let labels: [Label]

    public enum CodingKeys: CodingKey {
        case torrents
        case labels
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let torrentsDictionary = try container.decode([String: UnhashedTorrent].self, forKey: .torrents)

        torrents = torrentsDictionary.map { .init(hash: $0.key, torrent: $0.value) }
        labels = try container.decodeIfPresent([Label].self, forKey: .labels) ?? []
    }
}

private struct UnhashedTorrent: Decodable, Sendable {
    let dateAdded: Date?
    let downloaded: Int64?
    let downloadPath: String?
    let downloadRate: Int64?
    let eta: TimeInterval?
    let label: String?
    let name: String?
    let peers: Int?
    let progress: Float?
    let seeds: Int?
    let size: Int64?
    let state: Torrent.State?
    let totalPeers: Int?
    let totalSeeds: Int?
    let trackers: [Tracker]?
    let uploaded: Int64?
    let uploadRate: Int64?

    enum CodingKeys: String, CodingKey {
        case dateAdded = "time_added"
        case downloaded = "total_done"
        case downloadPath = "download_location"
        case downloadRate = "download_payload_rate"
        case eta
        case label
        case name
        case peers = "num_peers"
        case progress
        case seeds = "num_seeds"
        case size = "total_size"
        case state
        case totalPeers = "total_peers"
        case totalSeeds = "total_seeds"
        case trackers
        case uploaded = "total_uploaded"
        case uploadRate = "upload_payload_rate"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let dateAddedTime = try container.decodeIfPresent(Double.self, forKey: .dateAdded)
        if let dateAddedTime {
            dateAdded = Date(timeIntervalSince1970: dateAddedTime)
        } else {
            dateAdded = nil
        }

        downloaded = try container.decodeIfPresent(Int64.self, forKey: .downloaded)
        downloadPath = try container.decodeIfPresent(String.self, forKey: .downloadPath)
        downloadRate = try container.decodeIfPresent(Int64.self, forKey: .downloadRate)
        eta = try container.decodeIfPresent(TimeInterval.self, forKey: .eta)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        peers = try container.decodeIfPresent(Int.self, forKey: .peers)
        if let progressValue = try container.decodeIfPresent(Float.self, forKey: .progress) {
            progress = (progressValue / 100)
        } else {
            progress = nil
        }
        seeds = try container.decodeIfPresent(Int.self, forKey: .seeds)
        size = try container.decodeIfPresent(Int64.self, forKey: .size)
        state = try container.decodeIfPresent(Torrent.State.self, forKey: .state)
        totalPeers = try container.decodeIfPresent(Int.self, forKey: .totalPeers)
        totalSeeds = try container.decodeIfPresent(Int.self, forKey: .totalSeeds)
        trackers = try container.decodeIfPresent([Tracker].self, forKey: .trackers)
        uploaded = try container.decodeIfPresent(Int64.self, forKey: .uploaded)
        uploadRate = try container.decodeIfPresent(Int64.self, forKey: .uploadRate)
    }
}

private extension Torrent {
    init(hash: String, torrent: UnhashedTorrent) {
        self = .init(
            dateAdded: torrent.dateAdded,
            downloaded: torrent.downloaded,
            downloadPath: torrent.downloadPath,
            downloadRate: torrent.downloadRate,
            eta: torrent.eta,
            hash: hash,
            label: torrent.label,
            name: torrent.name,
            peers: torrent.peers,
            progress: torrent.progress,
            seeds: torrent.seeds,
            size: torrent.size,
            state: torrent.state,
            totalPeers: torrent.totalPeers,
            totalSeeds: torrent.totalSeeds,
            trackers: torrent.trackers,
            uploaded: torrent.uploaded,
            uploadRate: torrent.uploadRate
        )
    }
}
