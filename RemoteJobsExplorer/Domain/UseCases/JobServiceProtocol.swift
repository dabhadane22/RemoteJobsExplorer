import Foundation

public protocol JobServiceProtocol {
    /// Fetches a list of jobs based on specific parameters
    func fetchJobs(count: Int, tag: String?) async throws -> [APIJob]

    /// Saves jobs to local storage
    func saveJobs(_ jobs: [APIJob]) async throws
}

public enum JobServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
    case persistenceError(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "The provided URL is invalid."
        case .invalidResponse: return "The server returned an invalid response."
        case .decodingError:
            return "Failed to process the data."
        case .networkError:
            return "Network connection failed."
        case .persistenceError:
            return "Failed to save or load local data."
        }
    }
}
