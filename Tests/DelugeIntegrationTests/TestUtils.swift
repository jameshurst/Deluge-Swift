import Deluge
import Foundation
import Testing

func urlForResource(named resourceName: String) -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("Resources", isDirectory: true)
        .appendingPathComponent(resourceName)
}

func ensureTorrentAdded(
    fileURL: URL,
    to client: Deluge,
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column
) async throws {
    do {
        _ = try await client.request(.add(fileURL: fileURL))
    } catch {
        switch error {
        case .response(.torrentAlreadyInSession):
            return
        default:
            Issue.record(
                error,
                sourceLocation: SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
            )
        }
    }
}

func ensureTorrentRemoved(hash: String, from client: Deluge) async throws {
    try await client.request(.remove(hashes: [hash], removeData: false))
}

func ensurePluginEnabled(_ plugin: Plugin, from client: Deluge) async throws -> Bool {
    try await client.request(.enablePlugin(plugin))
}
