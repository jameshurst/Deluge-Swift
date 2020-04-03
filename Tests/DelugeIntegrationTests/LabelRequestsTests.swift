import Combine
import Deluge
import XCTest

class LabelRequestsTests: IntegrationTestCase {
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
}
