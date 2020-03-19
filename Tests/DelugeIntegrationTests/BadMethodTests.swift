import Combine
import Deluge
import XCTest

class BadMethodTests: XCTestCase {
    private var client: Deluge!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        client = Deluge(baseURL: TestConfig.serverURL, password: TestConfig.serverPassword)
        cancellables = Set()
    }

    func test_badMethod() {
        let bad = Request<Void>(method: "bad", args: []) { response in
            XCTFail("Unexpected response: \(String(describing: response))")
            return .failure(.unexpectedResponse)
        }
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 1
        client.request(bad)
            .sink(
                receiveCompletion: { completion in
                    defer { expectation.fulfill() }
                    guard case let .failure(error) = completion, case .serverError = error else {
                        XCTFail("Expected failure")
                        return
                    }
                },
                receiveValue: { _ in
                    XCTFail("Should not receive value")
                }
            )
            .store(in: &cancellables)
        waitForExpectations(timeout: 1)
    }
}
