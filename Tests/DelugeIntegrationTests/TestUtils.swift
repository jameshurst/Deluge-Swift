import Combine
import Deluge
import Foundation
import XCTest

func urlForResource(named resourceName: String) -> URL {
    URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .appendingPathComponent("Resources", isDirectory: true)
        .appendingPathComponent(resourceName)
}

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

func ensureTorrentAdded(fileURL: URL, to client: Deluge, file: StaticString = #file, line: UInt = #line) async throws {
    do {
        _ = try await client.request(.add(fileURL: fileURL))
    } catch {
        switch error {
        case .serverError(.torrentAlreadyInSession):
            return
        default:
            XCTFail(String(describing: error), file: file, line: line)
        }
    }
}

func ensureTorrentRemoved(
    hash: String,
    from client: Deluge,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    _ = try await client.request(.remove(hashes: [hash], removeData: false))
}
