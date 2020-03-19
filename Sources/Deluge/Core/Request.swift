import Combine
import Foundation

/// A definition for a Deluge JSON-RPC request.
public struct Request<Value> {
    /// The RPC method.
    public var method: String
    /// The arguments passed to the RPC method.
    public var args: [Any]
    /// Transforms the server response in to a new representation.
    public var transform: ([String: Any]) -> Result<Value, DelugeError>
    /// Whether authentication should be attempted if the server indicates that the client is unauthenticated.
    internal var authenticateIfNeeded: Bool
    /// Creates a new version of the request using information from the client.
    internal var prepare: (Self, Deluge) -> Self

    /// Creates a request with internal properties.
    /// - Parameters:
    ///   - method: The RPC method.
    ///   - args: The arguments passed to the RPC method.
    ///   - authenticateIfNeeded: Whether authentication should be attempted if the server indicates that the
    ///    client is unauthenticated.
    ///   - prepare: Creates a new version of the request using information from the client.
    ///   - transform: Transforms the server response in to a new representation.
    internal init(
        method: String,
        args: [Any],
        authenticateIfNeeded: Bool = true,
        prepare: @escaping (Self, Deluge) -> Self,
        transform: @escaping ([String: Any]) -> Result<Value, DelugeError>
    ) {
        self.method = method
        self.args = args
        self.authenticateIfNeeded = authenticateIfNeeded
        self.prepare = prepare
        self.transform = transform
    }

    /// Creates a request.
    /// - Parameters:
    ///   - method: The RPC method.
    ///   - args: The arguments passed to the RPC method.
    ///   - transform: Transforms the server response in to a new representation.
    public init(method: String, args: [Any], transform: @escaping ([String: Any]) -> Result<Value, DelugeError>) {
        self.init(method: method, args: args, prepare: { request, _ in request }, transform: transform)
    }
}

public extension Request where Value == Void {
    /// A convenience initializer for `Void` transforms. This provides a default transform implementation that simply
    /// returns a `Void` value.
    /// - Parameters:
    ///   - method: The RPC method.
    ///   - args: The arguments passed to the RPC method.
    init(method: String, args: [Any]) {
        self.init(method: method, args: args, transform: { _ in .success(()) })
    }
}

public extension Request {
    /// Creates a new request by mapping the `Value` of the request in to a new representation.
    /// - Parameter transform: Transforms the value in to a new representation.
    /// - Returns: The mapped request.
    func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Request<NewValue> {
        let original = self
        return Request<NewValue>(
            method: method,
            args: args,
            authenticateIfNeeded: authenticateIfNeeded,
            prepare: { request, client in
                let prepared = original.prepare(original, client)
                var request = request
                request.args = prepared.args
                return request
            },
            transform: { original.transform($0).map(transform) }
        )
    }
}
