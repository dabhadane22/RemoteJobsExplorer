import Foundation

/// A URLProtocol subclass that intercepts URLSession requests and returns
/// a stubbed response decided by `requestHandler`. Used for testing
/// `JobicyAPIClient` without making real network calls.
final class MockURLProtocol: URLProtocol {

    // MARK: – Configuration

    /// Set this before each test to control the mock HTTP response.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    // MARK: – URLProtocol overrides

    override static func canInit(with request: URLRequest) -> Bool {
        // Intercept every request
        return true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            let error = NSError(
                domain: "MockURLProtocol",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "No requestHandler set."])
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // Nothing to cancel for a synchronous mock
    }
}
