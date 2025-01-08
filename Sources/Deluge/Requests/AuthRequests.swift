public extension Request {
    /// Attempts to authenticate with the server. This will produce a `Void` value if authenticated.
    ///
    /// RPC Method: `auth.login`
    static var authenticate: Request<Void> {
        .init(
            method: "auth.login",
            args: [],
            authenticateIfNeeded: false,
            prepare: { request, client in
                var request = request
                request.args = [client.password]
                return request
            },
            transform: { response in
                let authenticated = response["result"] as? Bool ?? false
                guard authenticated else { return .failure(.serverError(.unauthenticated)) }
                return .success(())
            }
        )
    }
}
