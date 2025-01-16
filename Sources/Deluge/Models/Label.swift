/// A Deluge label.
public struct Label: Equatable, Decodable, Sendable {
    /// The label name.
    public var name: String
    /// The number of torrents with this label.
    public var count: Int
}
