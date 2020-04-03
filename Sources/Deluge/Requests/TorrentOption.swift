/// An option that can be set on a torrent.
public struct TorrentOption {
    /// The key identifying the option.
    ///
    /// Refer to
    /// [torrent.TorrentOption](https://git.deluge-torrent.org/deluge/tree/deluge/core/torrent.py) in the Deluge server
    /// source code for valid keys.
    public var key: String
    /// The value of the option.
    public var value: Any
}

public extension TorrentOption {
    /// Updates the file priorities for a torrent.
    ///
    /// Key: `file_priorities`
    ///
    /// The number of priority values should be equal to the number of files in the torrent.
    ///
    /// - Parameter priorities: The new file priorities for the torrent's files.
    static func filePriorities(_ priorities: [Priority]) -> Self {
        .init(key: "file_priorities", value: priorities.map(\.rawValue))
    }
}
