import APIClient
import Foundation

public extension Request {
    /// Creates a new request with the given method, arguments, and optional transform.
    ///
    /// This method is here to mirror the previous initializer for the Deluge Request.
    /// It will be deprecated in the future.
    ///
    /// - Parameters:
    ///   - method: The method to call.
    ///   - args: The arguments to pass to the method.
    ///   - transform: An optional transform to apply to the response data.
    init(
        method: String,
        args: [Any],
        transform: ((Data) throws -> Value)? = nil
    ) {
        self = .init(
            method: .post,
            path: nil,
            body: delugeFormatBody(method, parameters: args),
            transform: { try Self.handleTransform($0, injected: transform) }
        )
    }

    private static func handleTransform(_ data: Data, injected: ((Data) throws -> Value)?) throws -> Value {
        do {
            if let injected {
                let transformed = try injected(data)
                return transformed
            }

            let response = try JSONDecoder().decode(Deluge.Response<Value>.self, from: data)

            guard let error = response.error else {
                return response.result
            }

            throw DelugeClient.ResponseError.fromAPIError(error)
        } catch let error as DelugeClient.Error {
            throw error
        } catch {
            throw DelugeClient.Error.decoding(error)
        }
    }
}

private func delugeFormatBody(_ method: String, parameters: [Any]) -> [String: Any] {
    [
        "id": 1,
        "method": method,
        "params": parameters,
    ]
}
