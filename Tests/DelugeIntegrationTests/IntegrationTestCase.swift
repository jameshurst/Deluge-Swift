import Deluge
import XCTest

#if canImport(Combine)
    import Combine
#endif

class IntegrationTestCase: XCTestCase {
    var client: Deluge!

    #if canImport(Combine)
        var cancellables: Set<AnyCancellable>!
    #endif

    override func setUp() {
        super.setUp()
        client = Deluge(baseURL: TestConfig.serverURL, password: TestConfig.serverPassword)

        #if canImport(Combine)
            cancellables = Set()
        #endif
    }
}
