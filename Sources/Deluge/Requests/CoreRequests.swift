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
            args: [fileName, data, [String: Any]()],
            transform: { response in
                guard let hash = response["result"] as? String else { return .failure(.unexpectedResponse) }
                return .success(hash)
            }
        )
    }

    /// Adds multiple torrents using multiple URLs to local torrent files.
    ///
    /// RPC Method: `core.add_torrent_files`
    ///
    /// - Parameter fileURLs: The URLs of the local torrent files to add.
    static func add(fileURLs: [URL]) -> Request<Void> {
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
            args: [magnetURL.absoluteString, [String: Any]()],
            transform: { response in
                guard let hash = response["result"] as? String else { return .failure(.unexpectedResponse) }
                return .success(hash)
            }
        )
    }

    /// Adds a torrent using a web URL to a torrent file.
    ///
    /// RPC Method: `core.add_torrent_url`
    ///
    /// - Parameter url: The URL of the torrent file to add.
    static func add(url: URL) -> Request<Void> {
        .init(method: "core.add_torrent_url", args: [url.absoluteString, [String: Any]()])
    }

    /// Forces a reannounce for torrents with the given hashes.
    ///
    /// RPC Method: `core.force_reannounce`
    ///
    /// - Parameter hashes: The torrent hashes to force a reannounce on.
    static func reannounce(hashes: [String]) -> Request<Void> {
        .init(method: "core.force_reannounce", args: [hashes])
    }

    /// Rechecks torrents with the given hashes.
    ///
    /// RPC Method: `core.force_recheck`
    ///
    /// - Parameter hashes: The torrent hashes to recheck.
    static func recheck(hashes: [String]) -> Request<Void> {
        .init(method: "core.force_recheck", args: [hashes])
    }

    /// Moves the storage for torrents with the given hashes.
    ///
    /// RPC Method: `core.move_storage`
    ///
    /// - Parameters:
    ///   - hashes: The torrent hashes whose storage should be moved.
    ///   - path: The new path where the torrents' data should be stored.
    static func move(hashes: [String], path: String) -> Request<Void> {
        .init(method: "core.move_storage", args: [hashes, path])
    }

    /// Pauses torrents with the given hashes.
    ///
    /// RPC Method: `core.pause_torrents`
    ///
    /// - Parameter hashes: The torrent hashes to pause.
    static func pause(hashes: [String]) -> Request<Void> {
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
    static func remove(hashes: [String], removeData: Bool) -> Request<[(hash: String, message: String)]> {
        .init(
            method: "core.remove_torrents",
            args: [hashes, removeData],
            transform: { response in
                guard let errors = response["result"] as? [[String]] else { return .failure(.unexpectedResponse) }
                return .success(errors.map { error -> (String, String) in
                    (error.first ?? "", error.count > 1 ? error[1] : "")
                })
            }
        )
    }

    /// Resumes torrents with the given hashes.
    ///
    /// RPC Method: `core.resume_torrents`
    ///
    /// - Parameter hashes: The torrent hashes to resume.
    static func resume(hashes: [String]) -> Request<Void> {
        .init(method: "core.resume_torrents", args: [hashes])
    }
}
