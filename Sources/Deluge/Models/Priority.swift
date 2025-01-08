/// A priority value for Deluge downloads.
public struct Priority: RawRepresentable, Equatable, Hashable, Decodable, Sendable {
    public typealias RawValue = Int

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public extension Priority {
    /// The priority at which items are not downloaded. This has a `rawValue` of `0`.
    static let disabled = Priority(rawValue: 0)
    /// The low priority value. This has a `rawValue` of `1`.
    static let low = Priority(rawValue: 1)
    /// The normal priority value. This has a `rawValue` of `4`.
    static let normal = Priority(rawValue: 4)
    /// The high priority value. This has a `rawValue` of `7`.
    static let high = Priority(rawValue: 7)
}
