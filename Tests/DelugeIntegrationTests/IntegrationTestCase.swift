import Deluge

class IntegrationTestCase {
    let client: Deluge!

    init() {
        client = Deluge(baseURL: TestConfig.serverURL, password: TestConfig.serverPassword)
    }
}
