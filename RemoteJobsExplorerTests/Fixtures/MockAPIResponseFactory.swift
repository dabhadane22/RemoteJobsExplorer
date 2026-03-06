import Foundation

@testable import RemoteJobsExplorer

/// Factory helpers that build model instances for use in test suites.
enum MockAPIResponseFactory {

    // MARK: – APIJob

    /// Returns a fully-populated `APIJob` suitable for most tests.
    static func makeAPIJob(
        id: Int = 1,
        jobTitle: String = "Senior Python Developer",
        companyName: String = "Acme Corp",
        companyLogo: String? = "https://example.com/logo.png",
        jobGeo: String? = "Worldwide",
        jobLevel: String? = "Senior",
        jobType: [String]? = ["full_time"],
        jobIndustry: [String]? = ["Technology"],
        jobExcerpt: String? = "Join our remote Python team.",
        jobDescription: String? = "<p>Full job description here.</p>",
        url: String? = "https://jobicy.com/jobs/1-senior-python-developer",
        jobSlug: String? = "senior-python-developer",
        pubDate: String? = "2026-02-25T04:04:48+00:00",
        salaryMin: Int? = 100_000,
        salaryMax: Int? = 140_000,
        salaryCurrency: String? = "USD",
        salaryPeriod: String? = "year"
    ) -> APIJob {
        APIJob(
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

    /// Returns an `APIJob` with no optional salary / logo / date fields set.
    static func makeMinimalAPIJob(id: Int = 99) -> APIJob {
        APIJob(
            id: id,
            url: nil,
            jobSlug: nil,
            jobTitle: "Python Intern",
            companyName: "StartupX",
            companyLogo: nil,
            jobIndustry: nil,
            jobType: nil,
            jobGeo: nil,
            jobLevel: nil,
            jobExcerpt: nil,
            jobDescription: nil,
            pubDate: nil,
            salaryMin: nil,
            salaryMax: nil,
            salaryCurrency: nil,
            salaryPeriod: nil
        )
    }

    // MARK: – JobicyResponse JSON payloads

    /// Returns valid Jobicy JSON with `count` jobs embedded.
    static func makeValidResponseData(count: Int = 2) -> Data {
        let jobs = (1...max(1, count)).map { index -> String in
            """
            {
              "id": \(index),
              "url": "https://jobicy.com/jobs/\(index)",
              "jobSlug": "job-\(index)",
              "jobTitle": "Python Engineer \(index)",
              "companyName": "Company \(index)",
              "companyLogo": null,
              "jobIndustry": ["Technology"],
              "jobType": ["full_time"],
              "jobGeo": "Worldwide",
              "jobLevel": "Senior",
              "jobExcerpt": "We are looking for...",
              "jobDescription": "<p>Description \(index)</p>",
              "pubDate": "2026-02-25T04:04:48+00:00",
              "salaryMin": 90000,
              "salaryMax": 120000,
              "salaryCurrency": "USD",
              "salaryPeriod": "year"
            }
            """
        }.joined(separator: ",\n")

        let json = """
            {
              "apiVersion": "2",
              "documentationUrl": "https://jobicy.com/api-docs",
              "friendlyNotice": "Be nice.",
              "jobCount": \(count),
              "xRayCache": "HIT",
              "clientKey": "test-key",
              "lastUpdate": "2026-02-25T10:00:00+00:00",
              "appliedFilters": { "count": \(count), "tag": "python" },
              "success": true,
              "jobs": [\(jobs)]
            }
            """
        return Data(json.utf8)
    }

    /// Returns JSON where `jobs` is `null` (edge case).
    static func makeNullJobsResponseData() -> Data {
        let json = """
            {
              "apiVersion": "2",
              "success": true,
              "jobs": null
            }
            """
        return Data(json.utf8)
    }

    /// Returns syntactically invalid JSON.
    static func makeInvalidJSONData() -> Data {
        Data("NOT_JSON_AT_ALL{{{".utf8)
    }

    // MARK: – HTTP helpers

    static func makeHTTPResponse(
        statusCode: Int,
        url: URL = URL(string: "https://jobicy.com")!
    ) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
