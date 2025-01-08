/// An item contained in a torrent. This could be a file or a directory that contains more items.
public enum TorrentItem: Equatable, Sendable {
    /// A file item.
    case file(TorrentFile)
    /// A directory item that can contain more items.
    case directory(name: String, items: [TorrentItem])
}
