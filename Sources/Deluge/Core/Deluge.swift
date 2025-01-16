@_exported import APIClient
import Foundation
import Logging

#if canImport(Combine)
    import Combine
#endif

// URLSession in exists in FoundationNetworking on Linux
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// Convenience typealias for the Deluge client.
public typealias DelugeClient = Client<DelugeResponseError>

/// A Deluge JSON-RPC API client.
public final class Deluge: Sendable {
    /// The URL of the Deluge server.
    public let baseURL: URL
    /// The password used for authentication.
    public let password: String
    /// Basic authentication to be added to Authorization header.
    public let basicAuthentication: BasicAuthentication?

    /// The underlying API Client.
    private let client: DelugeClient

    private let logger: Logger

    /// Creates a Deluge client to interact with the given server URL.
    /// - Parameters:
    ///   - baseURL: The URL of the Deluge server.
    ///   - password: The password used for authentication.
    public init(baseURL: URL, password: String, basicAuthentication: BasicAuthentication? = nil) {
        LoggingSystem.bootstrap { identifier in
            var logger = StreamLogHandler.standardOutput(label: identifier)
#if DEBUG
            logger.logLevel = .debug
#else
            logger.logLevel = .info
#endif
            return logger
        }
        logger = Logger(label: "Deluge")

        self.baseURL = baseURL
        self.password = password
        self.basicAuthentication = basicAuthentication

        var headers = ["Content-Type": "application/json"]
        if let basicAuthentication {
            headers["Authorization"] = basicAuthentication.encoded
        }

        client = .init(
            baseURL: self.baseURL.appending(path: "json"),
            defaultHeaders: headers,
            validate: Self.validate
        )
    }

    @Sendable
    private static func validate(data: Data, response: HTTPURLResponse) throws(DelugeClient.Error) {
        guard response.statusCode == 200 else {
            throw .response(.message("Server returned non-200 status code: \(response.statusCode)"))
        }

        // Deluge returns 200, even for errors - which are wrapped in the response
        let response: Response<EmptyResponse>

        do {
            response = try JSONDecoder().decode(Response<EmptyResponse>.self, from: data)
        } catch let error as DecodingError {
            throw .decoding(error)
        } catch {
            throw .response(.unknown(error))
        }

        guard let error = response.error else { return }

        if error.code == 1 {
            throw .response(.unauthenticated)
        }

        let parts = [
            // "<class 'deluge.error.AddTorrentError'>: Torrent already in session",
            "Torrent already in session",
            // "<class 'deluge.error.WrappedException'>: type <class 'deluge.error.AddTorrentError'> not handled",
            "deluge.error.AddTorrentError",
        ]

        if parts.map({ error.message.contains($0) }).contains(true) {
            throw .response(.torrentAlreadyInSession)
        }

        throw .response(.message(error.message))
    }
}

#if canImport(Combine)
    /// Combine-powered extensions for `Deluge`.
    public extension Deluge {
        /// Sends a request to the server.
        /// - Parameter request: The request to be sent to the server.
        /// - Returns: A publisher that emits a value when the request completes.
        func request<Value>(_ request: Request<Value>) -> AnyPublisher<Value, DelugeClient.Error> {
            let retryIfNeeded = { (error: DelugeClient.Error) -> AnyPublisher<Value, DelugeClient.Error> in
                guard case .response(.unauthenticated) = error else {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }

                return self.request(.authenticate(self.password))
                    .flatMap { authenticated in
                        if !authenticated {
                            return Fail<Value, DelugeClient.Error>(error: DelugeClient.Error.response(.unauthenticated))
                                .eraseToAnyPublisher()
                        }

                        return self.client.request(request)
                    }
                    .eraseToAnyPublisher()
            }

            return client.request(request)
                .catch(retryIfNeeded)
                .eraseToAnyPublisher()
        }
    }
#endif

/// Swift Concurrency powered extensions for `Deluge`.
public extension Deluge {
    /// Sends a request to the server.
    /// - Parameter request: The request to be sent to the server.
    /// - Returns: A publisher that emits a value when the request completes.
    @discardableResult
    func request<Value>(_ request: Request<Value>) async throws(DelugeClient.Error) -> Value {
        do {
            return try await client.request(request)
        } catch {
            guard case .response(.unauthenticated) = error else {
                throw error
            }

            try await client.request(.authenticate(password))
            return try await client.request(request)
        }
    }
}

public extension Deluge {
    struct BasicAuthentication: Equatable, Codable, Sendable {
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
