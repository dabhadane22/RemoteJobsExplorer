import SwiftUI

public struct JobsListView: View {
    @StateObject private var viewModel: JobsListViewModel

    public init(viewModel: JobsListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView("Loading remote Python jobs...")
                        .controlSize(.large)
                        .tint(.blue)
                case .error(let message):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text(message)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchJobs()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                case .success(let jobs):
                    if jobs.isEmpty {
                        ContentUnavailableView(
                            "No Jobs Found", systemImage: "briefcase",
                            description: Text("Check back later or pull to refresh."))
                    } else {
                        List(jobs) { job in
                            NavigationLink(destination: JobDetailView(job: job)) {
                                JobRowView(job: job)
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.fetchJobs(isRefresh: true)
                        }
                    }
                }
            }
            .navigationTitle("Remote Python Jobs")
            .onAppear {
                if case .idle = viewModel.state {
                    Task {
                        await viewModel.fetchJobs()
                    }
                }
            }
        }
    }
}

struct JobRowView: View {
    let job: APIJob

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Company Logo
            AsyncImage(url: URL(string: job.companyLogo ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "building.2")
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(job.jobTitle)
                    .font(.headline)
                    .lineLimit(2)

                Text(job.companyName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Label(job.jobGeo ?? "Worldwide", systemImage: "globe")
                    Spacer()
                    if job.salaryPeriod != nil {
                        Text(job.formattedSalary)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                }
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
}
