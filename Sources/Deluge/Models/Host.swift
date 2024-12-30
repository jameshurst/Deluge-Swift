import Foundation

/// A Deluge host
public struct Host: Equatable {
    public typealias ID = String

    public let id: ID
    public let hostURL: URL
    public let port: Int
    public let name: String

    public static func == (lhs: Host, rhs: Host) -> Bool {
        lhs.id == rhs.id
    }
}
