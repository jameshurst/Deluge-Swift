import Combine
import Deluge
import XCTest

class AuthRequestsTests: XCTestCase {
    private var client: Deluge!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        client = Deluge(baseURL: TestConfig.serverURL, password: TestConfig.serverPassword)
        cancellables = Set()
    }

    func test_authenticate() {
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        client.request(.authenticate)
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
        waitForExpectations(timeout: 1)
    }
}
