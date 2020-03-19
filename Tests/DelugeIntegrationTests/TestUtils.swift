import Combine
import Deluge
import Foundation

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
