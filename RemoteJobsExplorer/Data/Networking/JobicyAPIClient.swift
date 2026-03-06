import Foundation

public actor JobicyAPIClient {
    private let baseURL = "https://jobicy.com/api/v2/remote-jobs"
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetchJobs(count: Int = 20, tag: String? = nil) async throws -> [APIJob] {
        var urlComponents = URLComponents(string: baseURL)
        var queryItems = [URLQueryItem(name: "count", value: "\(count)")]

        if let tag = tag, !tag.isEmpty {
            queryItems.append(URLQueryItem(name: "tag", value: tag))
        }

        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else {
            throw JobServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw JobServiceError.invalidResponse
        }

        // Handle rate limiting gracefully
        if httpResponse.statusCode == 429 {
            throw JobServiceError.networkError(
                NSError(
                    domain: "Too Many Requests", code: 429,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Rate limit exceeded. Please try again later."
                    ]))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw JobServiceError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            // Some API properties might be snake_case, but according to JSON it's camelCase mostly.
            let apiResponse = try decoder.decode(JobicyResponse.self, from: data)

            if let jobs = apiResponse.jobs {
                return jobs
            } else {
                print("No jobs found in API response")
                throw JobServiceError.invalidResponse
            }
        } catch {
            print("Decoding error: \(error)")
            throw JobServiceError.decodingError(error)
        }
    }
}
