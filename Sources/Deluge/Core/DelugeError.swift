import Foundation

/// Errors that can occur during Deluge operations.
public enum DelugeError: Error {
    /// An error occurred while encoding the request.
    case encoding(Error)
    /// An error occurred while decoding the response.
    case decoding(Error)
    /// An error occurred during the network request.
    case request(DelugeRequestError)
    /// The server returned an unexpected response.
    case unexpectedResponse
    /// An error returned by the server.
    case serverError(DelugeResponseError)
}

/// An error that occurred during a network request.
public enum DelugeRequestError: Error, Sendable {
    /// A typed `URLError`.
    case urlError(URLError)
    // Needed because `URLSession.data(for:)` throws `any Error`, sigh...
    /// An untyped `Error`.
    case unknown(Error)
}

/// An error returned by the server.
public enum DelugeResponseError: Error, Sendable {
    /// An error containing a message.
    case message(String?)
    /// The provided authentication was not valid.
    case unauthenticated
    /// The added torrent is already in the session.
    case torrentAlreadyInSession
    /// Until everything uses typed throws... this has to be here
    /// An untyped `Error`
    case unknown(Error)
}

extension DelugeResponseError {
    static func fromAPIError<Value: Decodable>(_ error: Deluge.Response<Value>.Error) -> Self {
        switch DelugeErrorCode(rawValue: error.code) {
        case .unauthenticated:
            return .unauthenticated
        case .rpcRequestErrorAsync:
            // There is a bug in deluge that adding a torrent that exists will return a stacktrace of a python
            // exception.
            // https://dev.deluge-torrent.org/ticket/3507
            if error.message.contains("<class \'deluge.error.AddTorrentError\'>: Torrent already in session") {
                return .torrentAlreadyInSession
            }
        case _:
            break
        }

        return .message(error.message)
    }
}

/// Error codes returned by the Deluge JSON-RPC API.
///
/// See [deluge/ui/web/json_api.py](https://github.com/deluge-torrent/deluge/blob/develop/deluge/ui/web/json_api.py)
private enum DelugeErrorCode: Int {
    /// The provided authentication was not valid.
    case unauthenticated = 1
    /// The requested RPC method does not exist.
    case unknownRpcMethod = 2
    /// A synchronous RPC method returned an error.
    case rpcRequestErrorSync = 3
    /// An asynchronous RPC method returned an error.
    ///
    /// This variant is for RPC methods that use `twisted.internet.defer.Deferred`.
    case rpcRequestErrorAsync = 4
    /// The JSON request could not be processed.
    case jsonRequestError = 5
}
