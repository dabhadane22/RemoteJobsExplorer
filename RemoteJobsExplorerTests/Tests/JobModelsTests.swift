import XCTest

@testable import RemoteJobsExplorer

/// Tests for `APIJob` computed properties: `formattedSalary` and `publicationDate`.
final class JobModelsTests: XCTestCase {

    // MARK: – formattedSalary

    func test_formattedSalary_withMinAndMax_returnsCurrencyRange() {
        let job = MockAPIResponseFactory.makeAPIJob(
            salaryMin: 100_000, salaryMax: 140_000,
            salaryCurrency: "USD", salaryPeriod: "year")

        let salary = job.formattedSalary
        // Verify both bounds are present and period is appended
        XCTAssertTrue(
            salary.contains("100"), "Expected lower bound in salary string, got: \(salary)")
        XCTAssertTrue(
            salary.contains("140"), "Expected upper bound in salary string, got: \(salary)")
        XCTAssertTrue(salary.contains("year"), "Expected period in salary string, got: \(salary)")
    }

    func test_formattedSalary_withMinOnly_returnsPlusFormat() {
        let job = MockAPIResponseFactory.makeAPIJob(
            salaryMin: 80_000, salaryMax: nil,
            salaryCurrency: "USD", salaryPeriod: "year")

        let salary = job.formattedSalary
        XCTAssertTrue(
            salary.contains("80"), "Expected lower bound in salary string, got: \(salary)")
        XCTAssertTrue(salary.contains("+"), "Expected '+' when no max is provided, got: \(salary)")
    }

    func test_formattedSalary_withNilSalary_returnsNotSpecified() {
        let job = MockAPIResponseFactory.makeMinimalAPIJob()

        XCTAssertEqual(job.formattedSalary, "Salary not specified")
    }

    func test_formattedSalary_withNilCurrency_returnsNotSpecified() {
        let job = MockAPIResponseFactory.makeAPIJob(
            salaryMin: 50_000, salaryCurrency: nil)

        XCTAssertEqual(job.formattedSalary, "Salary not specified")
    }

    // MARK: – publicationDate

    func test_publicationDate_validISO8601_returnsDate() {
        let job = MockAPIResponseFactory.makeAPIJob(pubDate: "2026-02-25T04:04:48+00:00")

        XCTAssertNotNil(job.publicationDate, "Expected a valid Date from a proper ISO8601 string")
    }

    func test_publicationDate_nilPubDate_returnsNil() {
        let job = MockAPIResponseFactory.makeAPIJob(pubDate: nil)

        XCTAssertNil(job.publicationDate, "Expected nil when pubDate is nil")
    }

    func test_publicationDate_invalidString_returnsNil() {
        let job = MockAPIResponseFactory.makeAPIJob(pubDate: "not-a-date")

        XCTAssertNil(job.publicationDate, "Expected nil for an unparseable date string")
    }
}
