import SwiftUI

public struct JobDetailView: View {
    public let job: APIJob

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(alignment: .center, spacing: 16) {
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
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 8) {
                        Text(job.jobTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(job.companyName)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                Divider()

                // Info Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    InfoTile(
                        title: "Location", value: job.jobGeo ?? "Worldwide",
                        icon: "mappin.and.ellipse")
                    if let type = job.jobType?.first {
                        InfoTile(title: "Job Type", value: type, icon: "clock")
                    }
                    InfoTile(title: "Salary", value: job.formattedSalary, icon: "dollarsign.circle")
                    if let pubDate = job.publicationDate {
                        InfoTile(
                            title: "Posted",
                            value: pubDate.formatted(date: .abbreviated, time: .omitted),
                            icon: "calendar")
                    }
                }
                .padding(.horizontal)

                Divider()

                // Job Description (HTML)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Job Description")
                        .font(.title3)
                        .fontWeight(.bold)

                    if let htmlString = job.jobDescription {
                        // The HTMLView needs a fixed height or it collapses in a ScrollView.
                        // Ideally, we'd calculate its content height, but for simplicity, we provide a tall frame.
                        HTMLView(htmlContent: htmlString)
                            .frame(minHeight: 1500)  // Simplistic workaround for WKWebView in ScrollView
                    } else if let excerpt = job.jobExcerpt {
                        Text(excerpt)
                            .font(.body)
                    } else {
                        Text("No description available.")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                // Apply Button
                if let urlString = job.url, let url = URL(string: urlString) {
                    Link(destination: url) {
                        Text("Apply Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Job Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoTile: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            Spacer()
        }
    }
}
