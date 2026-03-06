import XCTest

@testable import RemoteJobsExplorer

/// Tests for `JobicyAPIClient` using `MockURLProtocol` to intercept URLSession
/// network calls — no real internet is required.
final class JobicyAPIClientTests: XCTestCase {

    // MARK: – Properties

    private var mockSession: URLSession!
    private var client: JobicyAPIClient!

    // MARK: – Setup / Teardown

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
        client = JobicyAPIClient(session: mockSession)
        MockURLProtocol.requestHandler = nil
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        mockSession = nil
        client = nil
        super.tearDown()
    }

    // MARK: – Success path

    func test_fetchJobs_success_returnsExpectedJobs() async throws {
        // Given
        let expectedCount = 3
        let responseData = MockAPIResponseFactory.makeValidResponseData(count: expectedCount)
        MockURLProtocol.requestHandler = { request in
            let response = MockAPIResponseFactory.makeHTTPResponse(
                statusCode: 200, url: request.url!)
            return (response, responseData)
        }

        // When
        let jobs = try await client.fetchJobs(count: expectedCount, tag: "python")

        // Then
        XCTAssertEqual(
            jobs.count, expectedCount, "Expected \(expectedCount) jobs in the parsed response")
        XCTAssertEqual(jobs.first?.jobTitle, "Python Engineer 1")
    }

    // MARK: – URL construction

    func test_fetchJobs_buildsCorrectQueryParameters() async throws {
        // Given
        var capturedRequest: URLRequest?
        let responseData = MockAPIResponseFactory.makeValidResponseData(count: 1)
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let response = MockAPIResponseFactory.makeHTTPResponse(
                statusCode: 200, url: request.url!)
            return (response, responseData)
        }

        // When
        _ = try await client.fetchJobs(count: 10, tag: "python")

        // Then
        guard let url = capturedRequest?.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        else {
            return XCTFail("Could not extract URL components from captured request")
        }

        let countItem = queryItems.first(where: { $0.name == "count" })
        let tagItem = queryItems.first(where: { $0.name == "tag" })

        XCTAssertEqual(countItem?.value, "10", "Expected count=10 in query params")
        XCTAssertEqual(tagItem?.value, "python", "Expected tag=python in query params")
    }

    // MARK: – HTTP error paths

    func test_fetchJobs_http429_throwsNetworkError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = MockAPIResponseFactory.makeHTTPResponse(
                statusCode: 429, url: request.url!)
            return (response, Data())
        }

        // When / Then
        do {
            _ = try await client.fetchJobs(count: 5)
            XCTFail("Expected a networkError to be thrown for HTTP 429")
        } catch let error as JobServiceError {
            if case .networkError = error {
                // ✅ Expected
            } else {
                XCTFail("Expected JobServiceError.networkError, got: \(error)")
            }
        }
    }

    func test_fetchJobs_http500_throwsInvalidResponse() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = MockAPIResponseFactory.makeHTTPResponse(
                statusCode: 500, url: request.url!)
            return (response, Data())
        }

        // When / Then
        do {
            _ = try await client.fetchJobs(count: 5)
            XCTFail("Expected an invalidResponse error for HTTP 500")
        } catch let error as JobServiceError {
            if case .invalidResponse = error {
                // ✅ Expected
            } else {
                XCTFail("Expected JobServiceError.invalidResponse, got: \(error)")
            }
        }
    }

    // MARK: – Decoding error paths

    func test_fetchJobs_invalidJSON_throwsDecodingError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = MockAPIResponseFactory.makeHTTPResponse(
                statusCode: 200, url: request.url!)
            return (response, MockAPIResponseFactory.makeInvalidJSONData())
        }

        // When / Then
        do {
            _ = try await client.fetchJobs(count: 5)
            XCTFail("Expected a decodingError for invalid JSON")
        } catch let error as JobServiceError {
            if case .decodingError = error {
                // ✅ Expected
            } else {
                XCTFail("Expected JobServiceError.decodingError, got: \(error)")
            }
        }
    }

    func test_fetchJobs_nullJobsField_throwsInvalidResponse() async throws {
        // Given – JSON with `jobs: null`
        MockURLProtocol.requestHandler = { request in
            let response = MockAPIResponseFactory.makeHTTPResponse(
                statusCode: 200, url: request.url!)
            return (response, MockAPIResponseFactory.makeNullJobsResponseData())
        }

        // When / Then
        do {
            _ = try await client.fetchJobs(count: 5)
            XCTFail("Expected an invalidResponse error when jobs is null")
        } catch let error as JobServiceError {
            if case .invalidResponse = error {
                // ✅ Expected
            } else {
                XCTFail("Expected JobServiceError.invalidResponse, got: \(error)")
            }
        }
    }
}
