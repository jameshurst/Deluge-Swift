import Combine
import Foundation

/// A Deluge JSON-RPC API client.
public final class Deluge {
    /// The `URLSession` to use for requests.
    private lazy var session: URLSession = .shared

    /// The URL of the Deluge server.
    let baseURL: URL
    /// The password used for authentication.
    let password: String
    /// Basic authentication to be added to Authorization header.
    let basicAuthentication: BasicAuthentication?

    /// Creates a Deluge client to interact with the given server URL.
    /// - Parameters:
    ///   - baseURL: The URL of the Deluge server.
    ///   - password: The password used for authentication.
    public init(baseURL: URL, password: String, basicAuthentication: BasicAuthentication? = nil) {
        self.baseURL = baseURL
        self.password = password
        self.basicAuthentication = basicAuthentication
    }

    /// Attempts to create a `URLRequest` from a `Request`.
    /// - Parameter request: The request definition to be converted in to a `URLRequest`.
    /// - Returns: A `Result` containing either the created `URLRequest` or an error if the request was unable to be
    /// serialized to JSON.
    private func urlRequest<Value>(from request: Request<Value>) -> Result<URLRequest, DelugeError> {
        let url = baseURL.appendingPathComponent("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: [
                "id": 1,
                "method": request.method,
                "params": request.args,
            ], options: [])
        } catch {
            return .failure(.encoding(error))
        }

        if let basicAuthentication {
            urlRequest.setValue("Basic \(basicAuthentication.encoded)", forHTTPHeaderField: "Authorization")
        }

        return .success(urlRequest)
    }
}

/// Combine-powered extensions for `Deluge`.
extension Deluge {
    /// Sends a request to the server.
    /// - Parameter request: The request to be sent to the server.
    /// - Returns: A publisher that emits a value when the request completes.
    public func request<Value>(_ request: Request<Value>) -> AnyPublisher<Value, DelugeError> {
        send(request: request.prepare(request, self), authenticateIfNeeded: true)
            .flatMap { request.transform($0).publisher.eraseToAnyPublisher() }
            .eraseToAnyPublisher()
    }

    /// Sends a request to the server, optionally handling authentication.
    ///
    /// - Parameters:
    ///   - request: The request to be sent to the server.
    ///   - authenticateIfNeeded: Whether authentication should be attempted if the server responds that the client is
    ///   unauthenticated.
    /// - Returns: A publisher that emits the decoded server response.
    private func send<Value>(
        request: Request<Value>,
        authenticateIfNeeded: Bool
    ) -> AnyPublisher<[String: Any], DelugeError> {
        let retryIfNeeded = { (error: DelugeError) -> AnyPublisher<[String: Any], DelugeError> in
            guard case .unauthenticated = error, authenticateIfNeeded else {
                return Fail(error: error).eraseToAnyPublisher()
            }

            return self.request(.authenticate)
                .flatMap { self.send(request: request, authenticateIfNeeded: false) }
                .eraseToAnyPublisher()
        }

        return urlRequest(from: request).publisher
            .flatMap { self.session.dataTaskPublisher(for: $0).mapError { .request($0) } }
            .flatMap(decode(data:response:))
            .catch(retryIfNeeded)
            .eraseToAnyPublisher()
    }

    /// Attempts to decode a server response in to a dictionary.
    /// - Parameters:
    ///   - data: The data returned from the server.
    ///   - response: The `URLResponse` describing the server response.
    /// - Returns: A publisher that emits the decoded dictionary.
    private func decode(data: Data, response: URLResponse) -> AnyPublisher<[String: Any], DelugeError> {
        let dict: [String: Any]

        do {
            guard let object = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return Fail(error: .unexpectedResponse).eraseToAnyPublisher()
            }

            dict = object
        } catch {
            return Fail(error: .decoding(error)).eraseToAnyPublisher()
        }

        if let error = dict["error"] as? [String: Any] {
            if let code = error["code"] as? Int, code == 1 {
                return Fail(error: .unauthenticated).eraseToAnyPublisher()
            }

            if isTorrentAlreadyAddedException(message: error["message"] as? String) {
                return Fail(error: .torrentAlreadyAddedException).eraseToAnyPublisher()
            }

            return Fail(error: .serverError(message: error["message"] as? String)).eraseToAnyPublisher()
        }

        return Just(dict).setFailureType(to: DelugeError.self).eraseToAnyPublisher()
    }
}

/// Swift Concurrency powered extensions for `Deluge`.
extension Deluge {
    /// Sends a request to the server.
    /// - Parameter request: The request to be sent to the server.
    /// - Returns: A publisher that emits a value when the request completes.
    public func request<Value>(_ request: Request<Value>) async throws (DelugeError) -> Value {
        try request.transform(
            await send(
                request: request.prepare(request, self),
                authenticateIfNeeded: true
            )
        ).get()
    }

    /// Sends a request to the server, optionally handling authentication.
    ///
    /// - Parameters:
    ///   - request: The request to be sent to the server.
    ///   - authenticateIfNeeded: Whether authentication should be attempted if the server responds that the client is
    ///   unauthenticated.
    /// - Returns: A publisher that emits the decoded server response.
    private func send<Value>(
        request: Request<Value>,
        authenticateIfNeeded: Bool
    ) async throws (DelugeError) -> [String: Any] {
        do {
            let (data, response) = try await session.data(for: urlRequest(from: request).get())
            return try decode(data: data, response: response)
        } catch let error as DelugeError {
            guard case .unauthenticated = error, authenticateIfNeeded else {
                throw error
            }

            try await self.request(.authenticate)
            return try await send(request: request, authenticateIfNeeded: false)
        } catch let error as URLError {
            throw .request(error)
        } catch {
            throw .unknownRequestError(error)
        }
    }

    /// Attempts to decode a server response in to a dictionary.
    /// - Parameters:
    ///   - data: The data returned from the server.
    ///   - response: The `URLResponse` describing the server response.
    /// - Throws: A `DelugeError` if the response is malformed or contains an error.
    /// - Returns: The decoded dictionary.
    private func decode(data: Data, response: URLResponse) throws (DelugeError) -> [String: Any] {
        let dict: [String: Any]
        do {
            dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        } catch {
            throw .decoding(error)
        }

        if let error = dict["error"] as? [String: Any] {
            if let code = error["code"] as? Int, code == 1 {
                throw .unauthenticated
            }

            if isTorrentAlreadyAddedException(message: error["message"] as? String) {
                throw .torrentAlreadyAddedException
            }

            throw .serverError(message: error["message"] as? String)
        }

        return dict
    }

    private func isTorrentAlreadyAddedException(message: String?) -> Bool {
        // There is a bug in deluge that adding an already added torrent will return a stacktrace of a python exception...
        // Yes really... so instead we'll just try to add the same torrents as the combine test and ignore the error
        // if it looks like the addtorrent exception
        // https://dev.deluge-torrent.org/ticket/3507
        guard let message else {
            return false
        }

        let parts = [
            // "<class 'deluge.error.AddTorrentError'>: Torrent already in session",
            "Torrent already in session",
            // "<class 'deluge.error.WrappedException'>: type <class 'deluge.error.AddTorrentError'> not handled",
            "deluge.error.AddTorrentError",
        ]

        return parts.map { message.contains($0) }.contains(true)
    }
}

public extension Deluge {
    struct BasicAuthentication: Equatable, Codable {
        public let username: String
        public let password: String

        public init(username: String, password: String) {
            self.username = username
            self.password = password
        }

        var encoded: String {
            Data("\(username):\(password)".utf8).base64EncodedString()
        }
    }
}
