import Foundation

/// A Deluge host
public struct Host: Equatable, Decodable, Sendable {
    // swiftlint:disable:next type_name
    public typealias ID = String

    /// The ID of the host.
    public let id: ID
    /// The URL of the host.
    public let hostURL: URL
    /// The port number of the host.
    public let port: Int
    /// The name of the host.
    public let name: String

    public static func == (lhs: Host, rhs: Host) -> Bool {
        lhs.id == rhs.id
    }
}
