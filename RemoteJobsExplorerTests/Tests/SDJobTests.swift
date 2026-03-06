import XCTest

@testable import RemoteJobsExplorer

/// Tests for `SDJob` ↔ `APIJob` conversion (round-trip mapping).
final class SDJobTests: XCTestCase {

    // MARK: – SDJob(from: APIJob) field mapping

    func test_initFromAPIJob_preservesAllFields() {
        // Given
        let source = MockAPIResponseFactory.makeAPIJob(
            id: 42,
            jobTitle: "ML Engineer",
            companyName: "DeepMind",
            companyLogo: "https://example.com/logo.png",
            jobGeo: "Remote – UK",
            jobLevel: "Senior",
            jobType: ["full_time", "contract"],
            jobIndustry: ["AI", "Technology"],
            jobExcerpt: "Build models at scale.",
            jobDescription: "<p>Details here.</p>",
            url: "https://jobicy.com/jobs/42",
            jobSlug: "ml-engineer",
            pubDate: "2026-02-25T04:04:48+00:00",
            salaryMin: 120_000,
            salaryMax: 180_000,
            salaryCurrency: "GBP",
            salaryPeriod: "year"
        )

        // When
        let sdJob = SDJob(from: source)

        // Then – verify each mapped field
        XCTAssertEqual(sdJob.id, 42)
        XCTAssertEqual(sdJob.jobTitle, "ML Engineer")
        XCTAssertEqual(sdJob.companyName, "DeepMind")
        XCTAssertEqual(sdJob.companyLogo, "https://example.com/logo.png")
        XCTAssertEqual(sdJob.jobGeo, "Remote – UK")
        XCTAssertEqual(sdJob.jobLevel, "Senior")
        XCTAssertEqual(sdJob.jobType, ["full_time", "contract"])
        XCTAssertEqual(sdJob.jobIndustry, ["AI", "Technology"])
        XCTAssertEqual(sdJob.jobExcerpt, "Build models at scale.")
        XCTAssertEqual(sdJob.jobDescription, "<p>Details here.</p>")
        XCTAssertEqual(sdJob.url, "https://jobicy.com/jobs/42")
        XCTAssertEqual(sdJob.jobSlug, "ml-engineer")
        XCTAssertEqual(sdJob.pubDate, "2026-02-25T04:04:48+00:00")
        XCTAssertEqual(sdJob.salaryMin, 120_000)
        XCTAssertEqual(sdJob.salaryMax, 180_000)
        XCTAssertEqual(sdJob.salaryCurrency, "GBP")
        XCTAssertEqual(sdJob.salaryPeriod, "year")
    }

    // MARK: – toAPIJob() round-trip

    func test_toAPIJob_roundTripsAllFields() {
        // Given
        let original = MockAPIResponseFactory.makeAPIJob(id: 7)
        let sdJob = SDJob(from: original)

        // When
        let restored = sdJob.toAPIJob()

        // Then – round-tripped job must match original
        XCTAssertEqual(restored.id, original.id)
        XCTAssertEqual(restored.jobTitle, original.jobTitle)
        XCTAssertEqual(restored.companyName, original.companyName)
        XCTAssertEqual(restored.companyLogo, original.companyLogo)
        XCTAssertEqual(restored.jobGeo, original.jobGeo)
        XCTAssertEqual(restored.jobType, original.jobType)
        XCTAssertEqual(restored.jobIndustry, original.jobIndustry)
        XCTAssertEqual(restored.jobExcerpt, original.jobExcerpt)
        XCTAssertEqual(restored.jobDescription, original.jobDescription)
        XCTAssertEqual(restored.url, original.url)
        XCTAssertEqual(restored.pubDate, original.pubDate)
        XCTAssertEqual(restored.salaryMin, original.salaryMin)
        XCTAssertEqual(restored.salaryMax, original.salaryMax)
        XCTAssertEqual(restored.salaryCurrency, original.salaryCurrency)
        XCTAssertEqual(restored.salaryPeriod, original.salaryPeriod)
    }

    // MARK: – Optional / nil safety

    func test_initFromMinimalAPIJob_setsNilsCorrectly() {
        // Given – a job with only required fields
        let minimal = MockAPIResponseFactory.makeMinimalAPIJob(id: 99)

        // When
        let sdJob = SDJob(from: minimal)

        // Then – optional fields should all be nil
        XCTAssertNil(sdJob.companyLogo)
        XCTAssertNil(sdJob.jobGeo)
        XCTAssertNil(sdJob.jobLevel)
        XCTAssertNil(sdJob.jobType)
        XCTAssertNil(sdJob.jobIndustry)
        XCTAssertNil(sdJob.salaryMin)
        XCTAssertNil(sdJob.salaryMax)
        XCTAssertNil(sdJob.salaryCurrency)
        XCTAssertNil(sdJob.pubDate)
    }
}
