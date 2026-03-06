import Foundation
import SwiftData

@Model
public final class SDJob {
    @Attribute(.unique) public var id: Int
    public var url: String?
    public var jobSlug: String?
    public var jobTitle: String
    public var companyName: String
    public var companyLogo: String?
    public var jobIndustry: [String]?
    public var jobType: [String]?
    public var jobGeo: String?
    public var jobLevel: String?
    public var jobExcerpt: String?
    public var jobDescription: String?
    public var pubDate: String?

    public var salaryMin: Int?
    public var salaryMax: Int?
    public var salaryCurrency: String?
    public var salaryPeriod: String?

    // Store when we saved this to cache policies
    public var savedAt: Date

    public init(
        id: Int, url: String? = nil, jobSlug: String? = nil, jobTitle: String, companyName: String,
        companyLogo: String? = nil, jobIndustry: [String]? = nil, jobType: [String]? = nil,
        jobGeo: String? = nil, jobLevel: String? = nil, jobExcerpt: String? = nil,
        jobDescription: String? = nil, pubDate: String? = nil, salaryMin: Int? = nil,
        salaryMax: Int? = nil, salaryCurrency: String? = nil, salaryPeriod: String? = nil
    ) {
        self.id = id
        self.url = url
        self.jobSlug = jobSlug
        self.jobTitle = jobTitle
        self.companyName = companyName
        self.companyLogo = companyLogo
        self.jobIndustry = jobIndustry
        self.jobType = jobType
        self.jobGeo = jobGeo
        self.jobLevel = jobLevel
        self.jobExcerpt = jobExcerpt
        self.jobDescription = jobDescription
        self.pubDate = pubDate
        self.salaryMin = salaryMin
        self.salaryMax = salaryMax
        self.salaryCurrency = salaryCurrency
        self.salaryPeriod = salaryPeriod
        self.savedAt = Date()
    }

    // Convenience init to convert from Domain APIJob
    public convenience init(from apiJob: APIJob) {
        self.init(
            id: apiJob.id,
            url: apiJob.url,
            jobSlug: apiJob.jobSlug,
            jobTitle: apiJob.jobTitle,
            companyName: apiJob.companyName,
            companyLogo: apiJob.companyLogo,
            jobIndustry: apiJob.jobIndustry,
            jobType: apiJob.jobType,
            jobGeo: apiJob.jobGeo,
            jobLevel: apiJob.jobLevel,
            jobExcerpt: apiJob.jobExcerpt,
            jobDescription: apiJob.jobDescription,
            pubDate: apiJob.pubDate,
            salaryMin: apiJob.salaryMin,
            salaryMax: apiJob.salaryMax,
            salaryCurrency: apiJob.salaryCurrency,
            salaryPeriod: apiJob.salaryPeriod
        )
    }

    // Convert back to Domain APIJob
    public func toAPIJob() -> APIJob {
        return APIJob(
            id: id,
            url: url,
            jobSlug: jobSlug,
            jobTitle: jobTitle,
            companyName: companyName,
            companyLogo: companyLogo,
            jobIndustry: jobIndustry,
            jobType: jobType,
            jobGeo: jobGeo,
            jobLevel: jobLevel,
            jobExcerpt: jobExcerpt,
            jobDescription: jobDescription,
            pubDate: pubDate,
            salaryMin: salaryMin,
            salaryMax: salaryMax,
            salaryCurrency: salaryCurrency,
            salaryPeriod: salaryPeriod
        )
    }
}
