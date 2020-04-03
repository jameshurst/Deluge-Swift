import Combine
import Deluge
import XCTest

class SetOptionTests: IntegrationTestCase {
    func test_filePriorities() {
        let url = urlForResource(named: TestConfig.torrent1)
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        ensureTorrentAdded(fileURL: url, to: client)
            .flatMap { _ in
                self.client.request(.setOptions(
                    hashes: [TestConfig.torrent1Hash],
                    options: [.filePriorities([.disabled])]
                ))
            }
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
