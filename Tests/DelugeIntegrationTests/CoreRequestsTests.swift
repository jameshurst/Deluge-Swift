import Deluge
import Foundation
import Testing

#if canImport(Combine)
    import Combine
#endif

@Suite("Core Requests", .serialized)
struct CoreRequestsTests {
    #if canImport(Combine)
        @Test
        func test_addFileURL() async throws {
            let url = urlForResource(named: TestConfig.torrent2)

            try await ensureTorrentRemoved(hash: TestConfig.torrent2Hash, from: client)

            try await confirmation { confirmation in
                for try await hash in client.request(.add(fileURL: url)).values {
                    #expect(hash == TestConfig.torrent2Hash)
                    confirmation.confirm()
                }
            }
        }

        @Test
        func test_addFileURLs() async throws {
            let urls = [
                urlForResource(named: TestConfig.torrent3),
                urlForResource(named: TestConfig.torrent4),
            ]

            try await ensureTorrentRemoved(hash: TestConfig.torrent3Hash, from: client)
            try await ensureTorrentRemoved(hash: TestConfig.torrent4Hash, from: client)

            for try await _ in client.request(.add(fileURLs: urls)).values {}
        }

        @Test
        func test_addMagnetURL() async throws {
            let url = URL(string: TestConfig.magnetURL)!

            try await ensureTorrentRemoved(hash: TestConfig.magnetHash, from: client)

            try await confirmation { confirmation in
                for try await hash in client.request(.add(magnetURL: url)).values {
                    #expect(hash == TestConfig.magnetHash)
                    confirmation.confirm()
                }
            }
        }

        @Test
        func test_addURL() async throws {
            let url = URL(string: TestConfig.webURL)!

            try await ensureTorrentRemoved(hash: TestConfig.webURLHash, from: client)
            for try await _ in client.request(.add(url: url)).values {}
        }

        @Test
        func test_reannounce() async throws {
            let url = urlForResource(named: TestConfig.torrent1)

            try await ensureTorrentAdded(fileURL: url, to: client)
            for try await _ in client.request(.reannounce(hashes: [TestConfig.torrent1Hash])).values {}
        }

        @Test
        func test_recheck() async throws {
            let url = urlForResource(named: TestConfig.torrent1)

            try await ensureTorrentAdded(fileURL: url, to: client)
            for try await _ in client.request(.recheck(hashes: [TestConfig.torrent1Hash])).values {}
        }

        @Test
        func test_move() async throws {
            let url = urlForResource(named: TestConfig.torrent1)
            try await ensureTorrentAdded(fileURL: url, to: client)
            for try await _ in client.request(.move(hashes: [TestConfig.torrent1Hash], path: "/tmp")).values {}
        }

        @Test
        func test_removeTorrents_error() async throws {
            for try await errors in client.request(.remove(hashes: ["a"], removeData: false)).values {
                #expect(errors.count == 1)
                #expect(errors.first?.hash == "a")
            }
        }

        @Test
        func test_pause() async throws {
            let url = urlForResource(named: TestConfig.torrent1)
            try await ensureTorrentAdded(fileURL: url, to: client)
            for try await _ in client.request(.pause(hashes: [TestConfig.torrent1Hash])).values {}
        }

        @Test
        func test_resume() async throws {
            let url = urlForResource(named: TestConfig.torrent1)
            try await ensureTorrentAdded(fileURL: url, to: client)
            for try await _ in client.request(.resume(hashes: [TestConfig.torrent1Hash])).values {}
        }
    #endif

    @Test
    func test_addFileURL_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent2)
        try await ensureTorrentRemoved(hash: TestConfig.torrent2Hash, from: client)
        let hash = try await client.request(.add(fileURL: url))
        #expect(hash == TestConfig.torrent2Hash)
    }

    @Test
    func test_addFileURLs_concurrency() async throws {
        let urls = [
            urlForResource(named: TestConfig.torrent3),
            urlForResource(named: TestConfig.torrent4),
        ]

        try await ensureTorrentRemoved(hash: TestConfig.torrent3Hash, from: client)
        try await ensureTorrentRemoved(hash: TestConfig.torrent4Hash, from: client)

        try await client.request(.add(fileURLs: urls))
    }

    @Test
    func test_addMagnetURL_concurrency() async throws {
        let url = URL(string: TestConfig.magnetURL)!
        try await ensureTorrentRemoved(hash: TestConfig.magnetHash, from: client)

        let hash = try await client.request(.add(magnetURL: url))
        #expect(hash == TestConfig.magnetHash)
    }

    @Test
    func test_addURL_concurrency() async throws {
        let url = URL(string: TestConfig.webURL)!
        try await ensureTorrentRemoved(hash: TestConfig.webURLHash, from: client)
        try await client.request(.add(url: url))
    }

    @Test
    func test_reannounce_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.reannounce(hashes: [TestConfig.torrent1Hash]))
    }

    @Test
    func test_recheck_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.recheck(hashes: [TestConfig.torrent1Hash]))
    }

    @Test
    func test_move_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.move(hashes: [TestConfig.torrent1Hash], path: "/tmp"))
    }

    @Test
    func test_removeTorrents_error_concurrency() async throws {
        let errors = try await client.request(.remove(hashes: ["a"], removeData: false))
        #expect(errors.count == 1)
        #expect(errors.first?.hash == "a")
    }

    @Test
    func test_pause_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.pause(hashes: [TestConfig.torrent1Hash]))
    }

    @Test
    func test_resume_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.resume(hashes: [TestConfig.torrent1Hash]))
    }
}
