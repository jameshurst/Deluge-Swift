import Deluge
import Testing

#if canImport(Combine)
    import Combine
#endif

@Suite("Label Requests", .serialized)
class LabelRequestsTests: IntegrationTestCase {
    #if canImport(Combine)
        @Test()
        func test_setLabel() async throws {
            try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
            let url = urlForResource(named: TestConfig.torrent1)
            try await ensureTorrentAdded(fileURL: url, to: client)
            for try await _ in client.request(.setLabel(hash: TestConfig.torrent1Hash, label: "")).values {}
        }
    #endif

    @Test()
    func test_setLabel_concurrency() async throws {
        try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.setLabel(hash: TestConfig.torrent1Hash, label: ""))
    }
}
