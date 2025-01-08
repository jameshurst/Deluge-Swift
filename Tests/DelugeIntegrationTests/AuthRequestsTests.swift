import Deluge
import XCTest

#if canImport(Combine)
    import Combine
#endif

class AuthRequestsTests: IntegrationTestCase {
    #if canImport(Combine)
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
            waitForExpectations(timeout: TestConfig.timeout)
        }
    #endif

    func test_authenticate_concurrency() async throws {
        try await client.request(.authenticate)
    }
}
