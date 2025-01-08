import APIClient
import Foundation

public extension Request {
    init(
        method: String,
        args: [Any],
        autenticateIfNeeded: Bool = true,
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
