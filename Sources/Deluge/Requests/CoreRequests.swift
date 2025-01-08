import APIClient
import Foundation

public extension Request {
    /// Adds a torrent using a URL to a local torrent file.
    ///
    /// RPC Method: `core.add_torrent_file`
    ///
    /// Result: The added torrent's hash.
    ///
    /// - Parameter fileURL: The URL of the local torrent file to add.
    static func add(fileURL: URL) -> Request<String> {
        let fileName = fileURL.lastPathComponent
        let data = FileManager.default.contents(atPath: fileURL.path)?.base64EncodedString() ?? ""
        return .init(
            method: "core.add_torrent_file",
            args: [fileName, data, [String: Any]()]
        )
    }

    /// Adds multiple torrents using multiple URLs to local torrent files.
    ///
    /// RPC Method: `core.add_torrent_files`
    ///
    /// - Parameter fileURLs: The URLs of the local torrent files to add.
    static func add(fileURLs: [URL]) -> Request<EmptyResponse> {
        let files = fileURLs.map { url -> [Any] in
            let fileName = url.lastPathComponent
            let data = FileManager.default.contents(atPath: url.path)?.base64EncodedString() ?? ""
            return [fileName, data, [String: Any]()]
        }
        return .init(method: "core.add_torrent_files", args: [files])
    }

    /// Adds a torrent using a magnet URL.
    ///
    /// RPC Method: `core.add_torrent_magnet`
    ///
    /// Result: The added torrent's hash.
    ///
    /// - Parameter url: The magnet URL to add.
    static func add(magnetURL: URL) -> Request<String> {
        .init(
            method: "core.add_torrent_magnet",
            args: [magnetURL.absoluteString, [String: Any]()]
        )
    }

    /// Adds a torrent using a web URL to a torrent file.
    ///
    /// RPC Method: `core.add_torrent_url`
    ///
    /// - Parameter url: The URL of the torrent file to add.
    static func add(url: URL) -> Request<EmptyResponse> {
        .init(method: "core.add_torrent_url", args: [url.absoluteString, [String: Any]()])
    }

    /// Forces a reannounce for torrents with the given hashes.
    ///
    /// RPC Method: `core.force_reannounce`
    ///
    /// - Parameter hashes: The torrent hashes to force a reannounce on.
    static func reannounce(hashes: [String]) -> Request<EmptyResponse> {
        .init(method: "core.force_reannounce", args: [hashes])
    }

    /// Rechecks torrents with the given hashes.
    ///
    /// RPC Method: `core.force_recheck`
    ///
    /// - Parameter hashes: The torrent hashes to recheck.
    static func recheck(hashes: [String]) -> Request<EmptyResponse> {
        .init(method: "core.force_recheck", args: [hashes])
    }

    /// Moves the storage for torrents with the given hashes.
    ///
    /// RPC Method: `core.move_storage`
    ///
    /// - Parameters:
    ///   - hashes: The torrent hashes whose storage should be moved.
    ///   - path: The new path where the torrents' data should be stored.
    static func move(hashes: [String], path: String) -> Request<EmptyResponse> {
        .init(method: "core.move_storage", args: [hashes, path])
    }

    /// Pauses torrents with the given hashes.
    ///
    /// RPC Method: `core.pause_torrents`
    ///
    /// - Parameter hashes: The torrent hashes to pause.
    static func pause(hashes: [String]) -> Request<EmptyResponse> {
        .init(method: "core.pause_torrents", args: [hashes])
    }

    /// Removes torrents with the given hashes.
    ///
    /// RPC Method: `core.remove_torrents`
    ///
    /// Result: An array of torrent hashes and error messages, or an empty array if no errors occurred.
    ///
    /// - Parameters:
    ///   - hashes: The torrent hashes to remove.
    ///   - removeData: Whether the torrents' data should be removed.
    static func remove(hashes: [String], removeData: Bool) -> Request<[RemoveTorrentError]> {
        .init(
            method: "core.remove_torrents",
            args: [hashes, removeData],
            transform: { data in
                let response = try JSONDecoder().decode(Deluge.Response<[[String]]>.self, from: data)

                var errors = [RemoveTorrentError]()
                for result in response.result {
                    assert(result.count % 2 == 0)

                    var i = 0
                    while i < result.count {
                        errors.append(.init(hash: result[i], error: result[i + 1]))
                        i += 2
                    }
                }

                return errors
            }
        )
    }

    /// Resumes torrents with the given hashes.
    ///
    /// RPC Method: `core.resume_torrents`
    ///
    /// - Parameter hashes: The torrent hashes to resume.
    static func resume(hashes: [String]) -> Request<EmptyResponse> {
        .init(method: "core.resume_torrents", args: [hashes])
    }

    /// Sets options for torrents with the given hashes.
    ///
    /// RPC Method: `core.set_torrent_options`
    ///
    /// - Parameters:
    ///   - hashes: The torrent hashes to update.
    ///   - options: The options to set on the torrents.
    static func setOptions(hashes: [String], options: [TorrentOption]) -> Request<EmptyResponse> {
        .init(method: "core.set_torrent_options", args: [
            hashes,
            options.reduce(into: [String: Any]()) { $0[$1.key] = $1.value },
        ])
    }

    static func enablePlugin(_ plugin: Plugin) -> Request<Bool> {
        .init(method: "core.enable_plugin", args: [plugin.name])
    }

    static func disablePlugin(_ plugin: Plugin) -> Request<Bool> {
        .init(method: "core.disable_plugin", args: [plugin.name])
    }
}
