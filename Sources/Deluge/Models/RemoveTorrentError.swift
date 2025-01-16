public struct RemoveTorrentError: Decodable, Sendable {
    public let hash: String
    public let error: String
}
