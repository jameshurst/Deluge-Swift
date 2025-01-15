import Deluge
import Testing

#if canImport(Combine)
    import Combine
#endif

@Suite("Set Option Requests", .serialized)
struct SetOptionTests {
    #if canImport(Combine)
        @Test
        func test_filePriorities() async throws {
            let url = urlForResource(named: TestConfig.torrent1)
            try await ensureTorrentAdded(fileURL: url, to: client)
            let values = client.request(
                .setOptions(hashes: [TestConfig.torrent1Hash], options: [.filePriorities([.disabled])])
            ).values

            for try await _ in values {}
        }
    #endif

    @Test
    func test_filePriorities_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.setOptions(
            hashes: [TestConfig.torrent1Hash],
            options: [.filePriorities([.disabled])]
        ))
    }
}
