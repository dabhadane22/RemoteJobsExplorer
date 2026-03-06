import Foundation

@testable import RemoteJobsExplorer

/// A test-double conforming to `JobServiceProtocol` that lets each test
/// configure exactly what gets returned (or thrown) without any real
/// network or SwiftData involvement.
final class MockJobService: JobServiceProtocol {

    // MARK: – Stubs for fetchJobs(count:tag:)

    var stubbedJobs: [APIJob] = []
    var shouldThrowOnFetch: Bool = false
    var fetchError: Error = JobServiceError.networkError(
        NSError(
            domain: "MockJobService", code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Simulated network failure"]))

    /// Records the last call's arguments for assertion purposes.
    var lastFetchCount: Int?
    var lastFetchTag: String?

    func fetchJobs(count: Int, tag: String?) async throws -> [APIJob] {
        lastFetchCount = count
        lastFetchTag = tag
        if shouldThrowOnFetch { throw fetchError }
        return stubbedJobs
    }

    // MARK: – Stubs for saveJobs(_:)

    var savedJobs: [APIJob] = []
    var shouldThrowOnSave: Bool = false

    func saveJobs(_ jobs: [APIJob]) async throws {
        if shouldThrowOnSave {
            throw JobServiceError.persistenceError(
                NSError(domain: "MockJobService", code: -3, userInfo: nil))
        }
        savedJobs = jobs
    }
}
