/// An item contained in a torrent. This could be a file or a directory that contains more items.
public enum TorrentItem: Equatable, Decodable, Sendable {
    /// A file item.
    case file(TorrentFile)
    /// A directory item that can contain more items.
    case directory(name: String, items: [TorrentItem])
}

struct TorrentTree: Decodable, Sendable {
    enum TreeType: String, Decodable {
        case file
        case directory = "dir"
    }

    enum CodingKeys: CodingKey {
        case type
        case contents
    }

    let type: TreeType
    let contents: [String: TreeItem]

    func toItems() -> [TorrentItem] {
        contents
            .map {
                $0.value.toTorrentItem(named: $0.key)
            }
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(TreeType.self, forKey: .type)
        contents = try container.decode([String: TreeItem].self, forKey: .contents)
    }

    enum TreeItem: Decodable {
        case file(File)
        case directory(Directory)

        func toTorrentItem(named name: String) -> TorrentItem {
            switch self {
            case let .file(file):
                return .file(.init(name: name, file: file))
            case let .directory(directory):
                return .directory(name: name, items: directory.contents.map { $0.value.toTorrentItem(named: $0.key) })
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let file = try? container.decode(File.self) {
                self = .file(file)
            } else if let directory = try? container.decode(Directory.self) {
                self = .directory(directory)
            } else {
                throw DecodingError.typeMismatch(TreeItem.self, DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Value is neither a TreeFile nor a TreeDirectory"
                ))
            }
        }
    }

    struct File: Decodable, Sendable {
        let index: Int
        let path: String
        let size: Int64
        let progress: Float
        let priority: Priority
    }

    struct Directory: Decodable, Sendable {
        let contents: [String: TreeItem]

        enum CodingKeys: CodingKey {
            case contents
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            contents = try container.decode([String: TreeItem].self)
        }
    }
}

private extension TorrentFile {
    init(name: String, file: TorrentTree.File) {
        self = .init(
            index: file.index,
            name: name,
            path: file.path,
            size: file.size,
            progress: file.progress,
            priority: file.priority
        )
    }
}
