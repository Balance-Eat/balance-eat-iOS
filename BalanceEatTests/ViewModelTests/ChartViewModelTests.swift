//
//  ChartViewModelTests.swift
//  BalanceEatTests
//

@testable import BalanceEat
import XCTest
import RxSwift

@MainActor
final class ChartViewModelTests: XCTestCase {

    private var sut: ChartViewModel!
    private var mockUserUseCase: MockUserUseCase!
    private var mockStatsUseCase: MockStatsUseCase!
    private var disposeBag: DisposeBag!

    override func setUp() async throws {
        try await super.setUp()
        mockUserUseCase = MockUserUseCase()
        mockStatsUseCase = MockStatsUseCase()
        disposeBag = DisposeBag()
        sut = ChartViewModel(userUseCase: mockUserUseCase, statsUseCase: mockStatsUseCase)
    }

    override func tearDown() async throws {
        sut = nil
        mockUserUseCase = nil
        mockStatsUseCase = nil
        disposeBag = nil
        try await super.tearDown()
    }

    // MARK: - getUser

    func test_getUser_성공시_userDataRelay_업데이트() async {
        // Given
        let expectedUser = UserData.fixture(name: "홍길동")
        mockUserUseCase.getUserResult = .success(expectedUser)

        // When
        await sut.getUser()

        // Then
        XCTAssertEqual(sut.userDataRelay.value?.name, "홍길동")
    }

    func test_getUser_실패시_userDataRelay_nil_유지() async {
        // Given
        mockUserUseCase.getUserResult = .failure(.serverError(401))

        // When
        await sut.getUser()

        // Then
        XCTAssertNil(sut.userDataRelay.value)
    }

    func test_getUser_실패시_에러메시지_저장() async {
        // Given
        mockUserUseCase.getUserResult = .failure(.serverError(401))

        // When
        await sut.getUser()

        // Then
        XCTAssertNotNil(sut.toastMessageRelay.value)
    }

    func test_getUser_UUID없을때_서버_미호출() async {
        // Given
        mockUserUseCase.getUserUUIDResult = .failure(.readError("UUID 없음"))

        // When
        await sut.getUser()

        // Then: userDataRelay 변경 없음
        XCTAssertNil(sut.userDataRelay.value)
    }

    func test_getUser_로딩흐름_true후_false() async {
        // Given
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.getUser()

        // Then: [false(초기), true(시작), false(완료)]
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    // MARK: - getStats

    func test_getStats_성공시_currentStatsRelay_업데이트() async {
        // Given
        let stats = [StatsData.fixture(totalCalories: 2500)]
        mockStatsUseCase.getStatsResult = .success(stats)

        // When
        await sut.getStats(period: .daily)

        // Then
        XCTAssertEqual(sut.currentStatsRelay.value.count, 1)
        XCTAssertEqual(sut.currentStatsRelay.value.first?.totalCalories, 2500)
    }

    func test_getStats_성공시_캐시_저장() async {
        // Given
        let stats = [StatsData.fixture()]
        mockStatsUseCase.getStatsResult = .success(stats)

        // When
        await sut.getStats(period: .daily)

        // Then
        XCTAssertNotNil(sut.cachedStats[Period.daily.rawValue])
        XCTAssertEqual(sut.cachedStats[Period.daily.rawValue]?.count, 1)
    }

    func test_getStats_period별_캐시_독립_저장() async {
        // Given
        let dailyStats = [StatsData.fixture(type: .daily, totalCalories: 2000)]
        let weeklyStats = [StatsData.fixture(type: .weekly, totalCalories: 14000)]

        // When
        mockStatsUseCase.getStatsResult = .success(dailyStats)
        await sut.getStats(period: .daily)

        mockStatsUseCase.getStatsResult = .success(weeklyStats)
        await sut.getStats(period: .weekly)

        // Then: 두 period 모두 독립적으로 캐시됨
        XCTAssertEqual(sut.cachedStats[Period.daily.rawValue]?.first?.totalCalories, 2000)
        XCTAssertEqual(sut.cachedStats[Period.weekly.rawValue]?.first?.totalCalories, 14000)
    }

    func test_getStats_실패시_에러메시지_저장() async {
        // Given
        mockStatsUseCase.getStatsResult = .failure(.serverError(500))

        // When
        await sut.getStats(period: .daily)

        // Then
        XCTAssertNotNil(sut.toastMessageRelay.value)
    }

    func test_getStats_실패시_캐시_미변경() async {
        // Given
        mockStatsUseCase.getStatsResult = .failure(.serverError(500))

        // When
        await sut.getStats(period: .daily)

        // Then
        XCTAssertNil(sut.cachedStats[Period.daily.rawValue])
    }

    func test_getStats_로딩흐름_true후_false() async {
        // Given
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.getStats(period: .daily)

        // Then
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    func test_getStats_UseCase에_올바른_period_전달() async {
        // When
        await sut.getStats(period: .weekly)

        // Then
        XCTAssertEqual(mockStatsUseCase.capturedPeriod, .weekly)
    }
}
