import Deluge
import Testing

#if canImport(Combine)
    import Combine
#endif

@Suite("Web Requests")
class WebRequestsTests: IntegrationTestCase {
    #if canImport(Combine)
        @Test
        func test_updateUI() async throws {
            let url = urlForResource(named: TestConfig.torrent1)
            try await ensureTorrentAdded(fileURL: url, to: client)
            try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
            for try await state in client.request(.updateUI(properties: Torrent.PropertyKeys.allCases)).values {
                let torrent = state.torrents.first(where: { $0.hash == TestConfig.torrent1Hash })
                #expect(torrent?.dateAdded != nil)
                #expect(torrent?.downloaded != nil)
                #expect(torrent?.downloadPath != nil)
                #expect(torrent?.downloadRate != nil)
                #expect(torrent?.eta != nil)
                #expect(torrent?.label != nil)
                #expect(torrent?.name != nil)
                #expect(torrent?.peers != nil)
                #expect(torrent?.progress != nil)
                #expect(torrent?.seeds != nil)
                #expect(torrent?.size != nil)
                #expect(torrent?.state != nil)
                #expect(torrent?.totalPeers != nil)
                #expect(torrent?.totalSeeds != nil)
                #expect(torrent?.trackers == TestConfig.torrent1Trackers)
                #expect(torrent?.uploadRate != nil)
                #expect(torrent?.uploadRate != nil)
            }
        }

        @Test
        func test_torrentItems() async throws {
            let url = urlForResource(named: TestConfig.torrent1)
            try await ensureTorrentAdded(fileURL: url, to: client)
            for try await items in client.request(.torrentItems(hash: TestConfig.torrent1Hash)).values {
                #expect(items.count == 1)
                guard case let .file(file) = items.first else {
                    Issue.record("Unexpected item: \(String(describing: items.first))")
                    return
                }
                #expect(file.name == TestConfig.torrent1FileName)
            }
        }
    #endif

    @Test
    func test_updateUI_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
        try await ensureTorrentAdded(fileURL: url, to: client)
        let state = try await client.request(.updateUI(properties: Torrent.PropertyKeys.allCases))
        let torrent = state.torrents.first(where: { $0.hash == TestConfig.torrent1Hash })

        #expect(torrent?.dateAdded != nil)
        #expect(torrent?.downloaded != nil)
        #expect(torrent?.downloadPath != nil)
        #expect(torrent?.downloadRate != nil)
        #expect(torrent?.eta != nil)
        #expect(torrent?.label != nil)
        #expect(torrent?.name != nil)
        #expect(torrent?.peers != nil)
        #expect(torrent?.progress != nil)
        #expect(torrent?.seeds != nil)
        #expect(torrent?.size != nil)
        #expect(torrent?.state != nil)
        #expect(torrent?.totalPeers != nil)
        #expect(torrent?.totalSeeds != nil)
        #expect(torrent?.trackers == TestConfig.torrent1Trackers)
        #expect(torrent?.uploadRate != nil)
        #expect(torrent?.uploadRate != nil)
    }

    @Test
    func test_torrentItems_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)

        let items = try await client.request(.torrentItems(hash: TestConfig.torrent1Hash))
        #expect(items.count == 1)
        guard case let .file(file) = items.first else {
            Issue.record("Unexpected item: \(String(describing: items.first))")
            return
        }
        #expect(file.name == TestConfig.torrent1FileName)
    }

    @Test
    func test_plugins_concurrency() async throws {
        let plugins = try await client.request(.plugins)
        #expect(plugins.available.count == 10)
    }
}
