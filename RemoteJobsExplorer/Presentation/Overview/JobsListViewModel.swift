import Combine
import Foundation
import SwiftUI

public enum ViewState {
    case idle
    case loading
    case success([APIJob])
    case error(String)
}

@MainActor
public class JobsListViewModel: ObservableObject {
    @Published public var state: ViewState = .idle
    @Published public var jobs: [APIJob] = []

    // Inject the service interface rather than concrete implementation
    private let jobService: JobServiceProtocol

    public init(jobService: JobServiceProtocol) {
        self.jobService = jobService
    }

    public func fetchJobs(isRefresh: Bool = false) async {
        if !isRefresh {
            state = .loading
        }

        do {
            // Using default 20 count and 'python' tag based on requirements
            let fetchedJobs = try await jobService.fetchJobs(count: 20, tag: "python")
            self.jobs = fetchedJobs
            self.state = .success(fetchedJobs)
        } catch {
            print("Failed fetching jobs: \(error)")
            // Fallback to local if possible already handled in JobRepository,
            // but if that fails too, show an error.
            if let serviceError = error as? JobServiceError {
                self.state = .error(serviceError.localizedDescription)
            } else {
                self.state = .error("An unexpected error occurred.")
            }
        }
    }
}
