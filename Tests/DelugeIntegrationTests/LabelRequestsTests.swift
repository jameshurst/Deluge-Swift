import Deluge
import XCTest

#if canImport(Combine)
    import Combine
#endif

class LabelRequestsTests: IntegrationTestCase {
    #if canImport(Combine)
        func test_setLabel() {
            let url = urlForResource(named: TestConfig.torrent1)
            let expectation = self.expectation(description: #function)
            expectation.expectedFulfillmentCount = 2
            ensureTorrentAdded(fileURL: url, to: client)
                .flatMap { _ in self.client.request(.setLabel(hash: TestConfig.torrent1Hash, label: "")) }
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            XCTFail(String(describing: error))
                        }
                        expectation.fulfill()
                    },
                    receiveValue: { _ in
                        expectation.fulfill()
                    }
                )
                .store(in: &cancellables)
            waitForExpectations(timeout: TestConfig.timeout)
        }
    #endif

    func test_setLabel_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.setLabel(hash: TestConfig.torrent1Hash, label: ""))
    }
}
