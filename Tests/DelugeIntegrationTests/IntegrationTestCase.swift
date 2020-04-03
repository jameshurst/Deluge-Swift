import Combine
import Deluge
import XCTest

class IntegrationTestCase: XCTestCase {
    var client: Deluge!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        client = Deluge(baseURL: TestConfig.serverURL, password: TestConfig.serverPassword)
        cancellables = Set()
    }
}
