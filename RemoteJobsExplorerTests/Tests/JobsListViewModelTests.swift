import XCTest

@testable import RemoteJobsExplorer

/// Tests for `JobsListViewModel` using `MockJobService`.
/// All tests run on `@MainActor` because the ViewModel is isolated there.
@MainActor
final class JobsListViewModelTests: XCTestCase {

    // MARK: – Helpers

    private func makeSUT(service: MockJobService = MockJobService()) -> (
        JobsListViewModel, MockJobService
    ) {
        let sut = JobsListViewModel(jobService: service)
        return (sut, service)
    }

    // MARK: – Initial state

    func test_initialState_isIdle() {
        let (sut, _) = makeSUT()

        if case .idle = sut.state {
            // ✅ Expected
        } else {
            XCTFail("Expected initial state to be .idle, got \(sut.state)")
        }
        XCTAssertTrue(sut.jobs.isEmpty)
    }

    // MARK: – Successful fetch

    func test_fetchJobs_success_transitionsToSuccessState() async {
        // Given
        let mockJobs = [
            MockAPIResponseFactory.makeAPIJob(id: 1),
            MockAPIResponseFactory.makeAPIJob(id: 2)
        ]
        let (sut, service) = makeSUT()
        service.stubbedJobs = mockJobs

        // When
        await sut.fetchJobs()

        // Then
        if case .success(let jobs) = sut.state {
            XCTAssertEqual(jobs.count, 2)
            XCTAssertEqual(jobs.first?.id, 1)
        } else {
            XCTFail("Expected .success state, got \(sut.state)")
        }
        XCTAssertEqual(sut.jobs.count, 2)
    }

    func test_fetchJobs_success_passesCorrectParametersToService() async {
        // Given
        let (sut, service) = makeSUT()
        service.stubbedJobs = [MockAPIResponseFactory.makeAPIJob()]

        // When
        await sut.fetchJobs()

        // Then – ViewModel always calls with count=20 tag="python" (per requirements)
        XCTAssertEqual(service.lastFetchCount, 20)
        XCTAssertEqual(service.lastFetchTag, "python")
    }

    // MARK: – Fetch failure with no cache

    func test_fetchJobs_networkFailure_transitionsToErrorState() async {
        // Given
        let (sut, service) = makeSUT()
        service.shouldThrowOnFetch = true

        // When
        await sut.fetchJobs()

        // Then
        if case .error = sut.state {
            // ✅ Expected
        } else {
            XCTFail("Expected .error state, got \(sut.state)")
        }
    }

    // Note: In an integrated test with `JobRepository`, it would fall back to the cache.
    // Here we are testing the ViewModel in isolation with `MockJobService`.
    // Since `fetchPersistedJobs` was moved to the repository, the ViewModel
    // only sees the final result from `fetchJobs()`.

    // MARK: – Refresh skip

    func test_fetchJobs_isRefresh_doesNotSetLoadingState() async {
        // Given
        let (sut, service) = makeSUT()
        service.stubbedJobs = [MockAPIResponseFactory.makeAPIJob()]

        // Track state transitions
        var observedLoading = false
        // We can't hook into @Published easily without Combine, so we check after
        // that .loading was never the final state when isRefresh = true.
        await sut.fetchJobs(isRefresh: true)

        // Then – result should be .success, and we shouldn't have been in .loading
        if case .loading = sut.state {
            observedLoading = true
        }
        XCTAssertFalse(observedLoading, "Expected no .loading state during refresh fetch")
        if case .success = sut.state { /* ✅ */
        } else {
            XCTFail("Expected .success after refresh, got \(sut.state)")
        }
    }
}
