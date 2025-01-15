import Deluge
import Testing

#if canImport(Combine)
    import Combine
#endif

@Suite("Authentication Requests", .serialized)
struct AuthRequestsTests {
    #if canImport(Combine)
        @Test
        func test_authenticate() async throws {
            for try await authenticated in client.request(.authenticate(TestConfig.serverPassword)).values {
                #expect(authenticated == true)
            }
        }
    #endif

    @Test
    func test_authenticate_concurrency() async throws {
        let authenticated = try await client.request(.authenticate(TestConfig.serverPassword))
        #expect(authenticated == true)
    }
}
