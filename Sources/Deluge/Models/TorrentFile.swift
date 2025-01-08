/// A Deluge torrent file.
public struct TorrentFile: Equatable, Sendable {
    /// The index of the file.
    public var index: Int
    /// The name of the file.
    public var name: String
    /// The path of the file.
    public var path: String
    /// The size of the file in bytes.
    public var size: Int64
    /// The download progress of the file as a percentage. This is a value between 0 and 1.
    public var progress: Float
    /// The download priority of the file.
    public var priority: Priority

    /// Initializes a torrent file.
    public init(index: Int, name: String, path: String, size: Int64, progress: Float, priority: Priority) {
        self.index = index
        self.name = name
        self.path = path
        self.size = size
        self.progress = progress
        self.priority = priority
    }
}

extension TorrentFile {
    /// Initializes a torrent file using a response dictionary, returning nil if any required properties are missing.
    /// - Parameters:
    ///   - name: The file name.
    ///   - dictionary: The response dictionary for the file.
    init?(name: String, dictionary: [String: Any]) {
        guard let index = dictionary["index"] as? Int,
              let path = dictionary["path"] as? String,
              let size = dictionary["size"] as? Int64,
              let progress = (dictionary["progress"] as? Double).map(Float.init),
              let priority = dictionary["priority"] as? Int
        else {
            return nil
        }

        self.index = index
        self.name = name
        self.path = path
        self.size = size
        self.progress = progress
        self.priority = Priority(rawValue: priority)
    }
}
