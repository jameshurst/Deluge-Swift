import Deluge
import XCTest

#if canImport(Combine)
    import Combine
#endif

class WebRequestsTests: IntegrationTestCase {
    #if canImport(Combine)
        func test_updateUI() {
            let url = urlForResource(named: TestConfig.torrent1)
            let expectation = self.expectation(description: #function)
            expectation.expectedFulfillmentCount = 2
            ensureTorrentAdded(fileURL: url, to: client)
                .flatMap { _ in self.client.request(.updateUI(properties: Torrent.PropertyKeys.allCases)) }
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            XCTFail(String(describing: error))
                        }
                        expectation.fulfill()
                    },
                    receiveValue: { state in
                        let torrent = state.torrents.first(where: { $0.hash == TestConfig.torrent1Hash })
                        XCTAssertNotNil(torrent?.dateAdded)
                        XCTAssertNotNil(torrent?.downloaded)
                        XCTAssertNotNil(torrent?.downloadPath)
                        XCTAssertNotNil(torrent?.downloadRate)
                        XCTAssertNotNil(torrent?.eta)
                        XCTAssertNotNil(torrent?.label)
                        XCTAssertNotNil(torrent?.name)
                        XCTAssertNotNil(torrent?.peers)
                        XCTAssertNotNil(torrent?.progress)
                        XCTAssertNotNil(torrent?.seeds)
                        XCTAssertNotNil(torrent?.size)
                        XCTAssertNotNil(torrent?.state)
                        XCTAssertNotNil(torrent?.totalPeers)
                        XCTAssertNotNil(torrent?.totalSeeds)
                        XCTAssertEqual(torrent?.trackers, TestConfig.torrent1Trackers)
                        XCTAssertNotNil(torrent?.uploadRate)
                        XCTAssertNotNil(torrent?.uploadRate)
                        expectation.fulfill()
                    }
                )
                .store(in: &cancellables)
            waitForExpectations(timeout: TestConfig.timeout)
        }

        func test_torrentItems() {
            let url = urlForResource(named: TestConfig.torrent1)
            let expectation = self.expectation(description: #function)
            expectation.expectedFulfillmentCount = 2
            ensureTorrentAdded(fileURL: url, to: client)
                .flatMap { _ in self.client.request(.torrentItems(hash: TestConfig.torrent1Hash)) }
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            XCTFail(String(describing: error))
                        }
                        expectation.fulfill()
                    },
                    receiveValue: { items in
                        defer { expectation.fulfill() }
                        XCTAssertEqual(items.count, 1)
                        guard case let .file(file) = items.first else {
                            XCTFail("Unexpected item: \(String(describing: items.first))")
                            return
                        }
                        XCTAssertEqual(file.name, TestConfig.torrent1FileName)
                    }
                )
                .store(in: &cancellables)
            waitForExpectations(timeout: TestConfig.timeout)
        }
    #endif

    func test_updateUI_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        let state = try await client.request(.updateUI(properties: Torrent.PropertyKeys.allCases))
        let torrent = state.torrents.first(where: { $0.hash == TestConfig.torrent1Hash })

        XCTAssertNotNil(torrent?.dateAdded)
        XCTAssertNotNil(torrent?.downloaded)
        XCTAssertNotNil(torrent?.downloadPath)
        XCTAssertNotNil(torrent?.downloadRate)
        XCTAssertNotNil(torrent?.eta)
        XCTAssertNotNil(torrent?.label)
        XCTAssertNotNil(torrent?.name)
        XCTAssertNotNil(torrent?.peers)
        XCTAssertNotNil(torrent?.progress)
        XCTAssertNotNil(torrent?.seeds)
        XCTAssertNotNil(torrent?.size)
        XCTAssertNotNil(torrent?.state)
        XCTAssertNotNil(torrent?.totalPeers)
        XCTAssertNotNil(torrent?.totalSeeds)
        XCTAssertEqual(torrent?.trackers, TestConfig.torrent1Trackers)
        XCTAssertNotNil(torrent?.uploadRate)
        XCTAssertNotNil(torrent?.uploadRate)
    }

    func test_torrentItems_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)

        let items = try await client.request(.torrentItems(hash: TestConfig.torrent1Hash))
        XCTAssertEqual(items.count, 1)
        guard case let .file(file) = items.first else {
            XCTFail("Unexpected item: \(String(describing: items.first))")
            return
        }
        XCTAssertEqual(file.name, TestConfig.torrent1FileName)
    }
}
