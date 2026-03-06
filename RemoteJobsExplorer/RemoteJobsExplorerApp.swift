import SwiftUI

@main
struct RemoteJobsExplorerApp: App {
    // Inject dependencies
    private let jobRepository = JobRepository()

    var body: some Scene {
        WindowGroup {
            JobsListView(viewModel: JobsListViewModel(jobService: jobRepository))
        }
    }
}
