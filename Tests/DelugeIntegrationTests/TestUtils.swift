import Deluge
import Foundation
import Testing

#if canImport(Combine)
    import Combine
#endif

func urlForResource(named resourceName: String) -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("Resources", isDirectory: true)
        .appendingPathComponent(resourceName)
}

#if canImport(Combine)
    func ensureTorrentAdded(fileURL: URL, to client: Deluge) -> AnyPublisher<Void, DelugeError> {
        client.request(.add(fileURL: fileURL))
            .map { _ in () }
            .replaceError(with: ())
            .setFailureType(to: DelugeError.self)
            .eraseToAnyPublisher()
    }

    // When migrated to Swift Testing: tests that use this may stomp each other
    // figure out how to fix that (or switch to swift testing???)
    func ensureTorrentRemoved(hash: String, from client: Deluge) -> AnyPublisher<Void, DelugeError> {
        client.request(.remove(hashes: [hash], removeData: false))
            .map { _ in () }
            .replaceError(with: ())
            .setFailureType(to: DelugeError.self)
            .eraseToAnyPublisher()
    }
#endif

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

func isPluginEnabled(_ string: String, on client: Deluge) async throws -> Bool {
    let plugins = try await client.request(.plugins)
    return plugins.enabled.contains(where: { $0.name == string })
}

func ensureTorrentRemoved(
    hash: String,
    from client: Deluge,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await client.request(.remove(hashes: [hash], removeData: false))
}

func ensurePluginEnabled(_ plugin: Plugin, from client: Deluge) async throws -> Bool {
    try await client.request(.enablePlugin(plugin))
}
