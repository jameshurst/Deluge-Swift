import Foundation

/// Errors that can occur during Deluge operations.
public enum DelugeError: Error {
    /// An error occurred while encoding the request.
    case encoding(Error)
    /// An error occurred while decoding the response.
    case decoding(Error)
    /// A request error occurred.
    case request(URLError)
    /// The provided authentication was not valid.
    case unauthenticated
    /// The server returned an unexpected response.
    case unexpectedResponse
    /// The server returned an error message.
    case serverError(message: String?)
}
