import Foundation

/// Represents the top-level response from the Jobicy API.
public struct JobicyResponse: Codable {
    public let apiVersion: String?
    public let documentationUrl: String?
    public let friendlyNotice: String?
    public let jobCount: Int?
    public let xRayCache: String?
    public let clientKey: String?
    public let lastUpdate: String?
    public let appliedFilters: AppliedFilters?
    public let jobs: [APIJob]?
    public let success: Bool?
}

/// Represents the applied filters in the API response.
public struct AppliedFilters: Codable {
    public let count: Int?
    public let tag: String?
}

/// Represents the actual Job object returned by the API.
public struct APIJob: Codable, Identifiable, Hashable {
    public let id: Int
    public let url: String?
    public let jobSlug: String?
    public let jobTitle: String
    public let companyName: String
    public let companyLogo: String?
    public let jobIndustry: [String]?
    public let jobType: [String]?
    public let jobGeo: String?
    public let jobLevel: String?
    public let jobExcerpt: String?
    public let jobDescription: String?
    public let pubDate: String?

    // Salary info
    public let salaryMin: Int?
    public let salaryMax: Int?
    public let salaryCurrency: String?
    public let salaryPeriod: String?

    // Custom property for formatted salary
    public var formattedSalary: String {
        guard let salaryMin = salaryMin, let currency = salaryCurrency else {
            return "Salary not specified"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 0

        let minStr = formatter.string(from: NSNumber(value: salaryMin)) ?? "\(salaryMin)"

        if let max = salaryMax {
            let maxStr = formatter.string(from: NSNumber(value: max)) ?? "\(max)"
            return "\(minStr) - \(maxStr) / \(salaryPeriod ?? "year")"
        } else {
            return "\(minStr)+ / \(salaryPeriod ?? "year")"
        }
    }

    // Custom property to get Date from pubDate string
    public var publicationDate: Date? {
        guard let pubDate = pubDate else { return nil }
        let formatter = ISO8601DateFormatter()
        // API returns 2026-02-25T04:04:48+00:00 structure
        return formatter.date(from: pubDate)
    }
}
