import APIClient
import Deluge
import Testing

#if canImport(Combine)
    import Combine
#endif

@Suite("Bad Method", .serialized)
class BadMethodTests: IntegrationTestCase {
    #if canImport(Combine)
        @Test
        func test_badMethod() async {
            let bad = Request<EmptyResponse>(method: "bad", args: []) { _ in
                throw DelugeClient.Error.response(.message(nil))
            }

            await confirmation { confirmation in
                do {
                    for try await _ in client.request(bad).values {
                        Issue.record("Should not recieve value")
                    }
                } catch let error as DelugeClient.Error {
                    switch error {
                    case let .response(.message(error)):
                        #expect(error == "Unknown method")
                        confirmation.confirm()
                    default:
                        Issue.record("Unexpected error: \(error)")
                    }
                } catch {
                    Issue.record("Unexpected error: \(error)")
                }
            }
        }
    #endif

    @Test
    func test_badMethod_concurrency() async throws {
        let bad = Request<EmptyResponse>(method: "bad", args: []) { _ in
            throw DelugeClient.Error.response(.message(nil))
        }

        do {
            try await client.request(bad)
            Issue.record("Expected error")
        } catch {
            switch error {
            case let .response(.message(error)):
                #expect(error == "Unknown method")
            default:
                Issue.record("Unexpected error: \(error)")
            }
        }
    }
}
