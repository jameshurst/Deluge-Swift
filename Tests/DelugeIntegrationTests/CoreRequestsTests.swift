import Combine
import Deluge
import XCTest

class CoreRequestsTests: IntegrationTestCase {
    func test_addFileURL() {
        let url = urlForResource(named: TestConfig.torrent2)
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        ensureTorrentRemoved(hash: TestConfig.torrent2Hash, from: client)
            .flatMap { self.client.request(.add(fileURL: url)) }
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                       XCTFail(String(describing: error))
                    }
                    expectation.fulfill()
                },
                receiveValue: { hash in
                    XCTAssertEqual(hash, TestConfig.torrent2Hash)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        waitForExpectations(timeout: TestConfig.timeout)
    }

    func test_addFileURL_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent2)
        try await ensureTorrentRemoved(hash: TestConfig.torrent2Hash, from: client)
        let hash = try await client.request(.add(fileURL: url))
        XCTAssertEqual(hash, TestConfig.torrent2Hash)
    }

    func test_addFileURLs() {
        let urls = [
            urlForResource(named: TestConfig.torrent3),
            urlForResource(named: TestConfig.torrent4),
        ]
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        ensureTorrentRemoved(hash: TestConfig.torrent3Hash, from: client)
            .flatMap { ensureTorrentRemoved(hash: TestConfig.torrent4Hash, from: self.client) }
            .flatMap { self.client.request(.add(fileURLs: urls)) }
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

    func test_addFileURLs_concurrency() async throws {
        let urls = [
            urlForResource(named: TestConfig.torrent3),
            urlForResource(named: TestConfig.torrent4),
        ]

        try await ensureTorrentRemoved(hash: TestConfig.torrent3Hash, from: client)
        try await ensureTorrentRemoved(hash: TestConfig.torrent4Hash, from: client)

        try await client.request(.add(fileURLs: urls))
    }

    func test_addMagnetURL() {
        let url = URL(string: TestConfig.magnetURL)!
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        ensureTorrentRemoved(hash: TestConfig.magnetHash, from: client)
            .flatMap { self.client.request(.add(magnetURL: url)) }
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        XCTFail(String(describing: error))
                    }
                    expectation.fulfill()
                },
                receiveValue: { hash in
                    XCTAssertEqual(hash, TestConfig.magnetHash)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        waitForExpectations(timeout: TestConfig.timeout)
    }

    func test_addMagnetURL_concurrency() async throws {
        let url = URL(string: TestConfig.magnetURL)!
        try await ensureTorrentRemoved(hash: TestConfig.magnetHash, from: client)

        let hash = try await client.request(.add(magnetURL: url))
        XCTAssertEqual(hash, TestConfig.magnetHash)
    }

    func test_addURL() {
        let url = URL(string: TestConfig.webURL)!
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        ensureTorrentRemoved(hash: TestConfig.webURLHash, from: client)
            .flatMap { self.client.request(.add(url: url)) }
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
        waitForExpectations(timeout: 2)
    }

    func test_addURL_concurrency() async throws {
        let url = URL(string: TestConfig.webURL)!
        try await ensureTorrentRemoved(hash: TestConfig.webURLHash, from: client)
        try await client.request(.add(url: url))
    }

    func test_reannounce() {
        let url = urlForResource(named: TestConfig.torrent1)
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        ensureTorrentAdded(fileURL: url, to: client)
            .flatMap { _ in self.client.request(.reannounce(hashes: [TestConfig.torrent1Hash])) }
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

    func test_reannounce_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.reannounce(hashes: [TestConfig.torrent1Hash]))
    }

    func test_recheck() {
        let url = urlForResource(named: TestConfig.torrent1)
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        ensureTorrentAdded(fileURL: url, to: client)
            .flatMap { _ in self.client.request(.recheck(hashes: [TestConfig.torrent1Hash])) }
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

    func test_recheck_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.recheck(hashes: [TestConfig.torrent1Hash]))
    }

    func test_move() {
        let url = urlForResource(named: TestConfig.torrent1)
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        ensureTorrentAdded(fileURL: url, to: client)
            .flatMap { _ in self.client.request(.move(hashes: [TestConfig.torrent1Hash], path: "/tmp")) }
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

    func test_move_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.move(hashes: [TestConfig.torrent1Hash], path: "/tmp"))
    }

    func test_removeTorrents_error() {
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        client.request(.remove(hashes: ["a"], removeData: false))
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        XCTFail(String(describing: error))
                    }
                    expectation.fulfill()
                },
                receiveValue: { errors in
                    XCTAssertEqual(errors.count, 1)
                    XCTAssertEqual(errors.first?.hash, "a")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        waitForExpectations(timeout: TestConfig.timeout)
    }

    func test_removeTorrents_error_concurrency() async throws {
        let errors = try await client.request(.remove(hashes: ["a"], removeData: false))
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors.first?.hash, "a")
    }

    func test_pause() {
        let url = urlForResource(named: TestConfig.torrent1)
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        ensureTorrentAdded(fileURL: url, to: client)
            .flatMap { _ in self.client.request(.pause(hashes: [TestConfig.torrent1Hash])) }
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

    func test_pause_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.pause(hashes: [TestConfig.torrent1Hash]))
    }

    func test_resume() {
        let url = urlForResource(named: TestConfig.torrent1)
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        ensureTorrentAdded(fileURL: url, to: client)
            .flatMap { _ in self.client.request(.resume(hashes: [TestConfig.torrent1Hash])) }
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

    func test_resume_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.resume(hashes: [TestConfig.torrent1Hash]))
    }
}
