import Foundation
import SwiftData

@MainActor
public class JobRepository: JobServiceProtocol {
    private let apiClient: JobicyAPIClient
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    public init(apiClient: JobicyAPIClient = JobicyAPIClient()) {
        self.apiClient = apiClient

        do {
            let schema = Schema([SDJob.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.modelContainer = try ModelContainer(
                for: schema, configurations: [modelConfiguration])
            self.modelContext = modelContainer.mainContext
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    public func fetchJobs(count: Int, tag: String?) async throws -> [APIJob] {
        do {
            // Attempt to fetch from network first
            let remoteJobs = try await apiClient.fetchJobs(count: count, tag: tag)

            // If successful, save to persistence mapping domain models to SD models
            try await saveJobs(remoteJobs)

            return remoteJobs
        } catch {
            // If network fails (e.g., offline or rate limit), try loading from persistence
            print(
                "Network request failed: \(error.localizedDescription). Falling back to local data."
            )
            let localJobs = try await fetchPersistedJobs()
            if localJobs.isEmpty {
                // Return the original network or decoding error if no cache exists
                if let serviceError = error as? JobServiceError {
                    throw serviceError
                }
                throw JobServiceError.networkError(error)
            }
            return localJobs
        }
    }

    private func fetchPersistedJobs() async throws -> [APIJob] {
        let fetchDescriptor = FetchDescriptor<SDJob>()
        do {
            let localJobs = try modelContext.fetch(fetchDescriptor)
            return localJobs.sorted(by: { $0.savedAt > $1.savedAt }).map { $0.toAPIJob() }
        } catch {
            throw JobServiceError.persistenceError(error)
        }
    }

    public func saveJobs(_ jobs: [APIJob]) async throws {
        // Simple cache invalidation: Replace all existing jobs (for simplicity of the showcase)
        // Alternatively, could update based on ID.
        for sdJob in jobs.map({ SDJob(from: $0) }) {
            modelContext.insert(sdJob)
        }

        do {
            try modelContext.save()
        } catch {
            throw JobServiceError.persistenceError(error)
        }
    }
}
