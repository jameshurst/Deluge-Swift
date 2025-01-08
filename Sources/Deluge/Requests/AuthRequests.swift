import APIClient

public extension Request {
    /// Attempts to authenticate with the server. This will produce a `Void` value if authenticated.
    ///
    /// RPC Method: `auth.login`
    static func authenticate(_ password: String) -> Request<Bool> {
        .init(
            method: "auth.login",
            args: [password]
        )
    }
}
