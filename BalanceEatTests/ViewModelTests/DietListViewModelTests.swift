//
//  DietListViewModelTests.swift
//  BalanceEatTests
//

@testable import BalanceEat
import XCTest
import RxSwift

@MainActor
final class DietListViewModelTests: XCTestCase {

    private var sut: DietListViewModel!
    private var mockUserUseCase: MockUserUseCase!
    private var mockDietUseCase: MockDietUseCase!
    private var disposeBag: DisposeBag!

    override func setUp() async throws {
        try await super.setUp()
        mockUserUseCase = MockUserUseCase()
        mockDietUseCase = MockDietUseCase()
        disposeBag = DisposeBag()
        sut = DietListViewModel(userUseCase: mockUserUseCase, dietUseCase: mockDietUseCase)
        // setBinding에서 selectedDate 초기값 처리로 생성되는 부동 Task가 완료될 때까지 대기
        await Task.yield()
    }

    override func tearDown() async throws {
        sut = nil
        mockUserUseCase = nil
        mockDietUseCase = nil
        disposeBag = nil
        try await super.tearDown()
    }

    // MARK: - getUser: 결과 검증

    func test_getUser_성공시_userDataRelay_업데이트() async {
        // Given
        let expectedUser = UserData.fixture(name: "홍길동")
        mockUserUseCase.getUserResult = .success(expectedUser)

        // When
        await sut.getUser()

        // Then
        XCTAssertEqual(sut.userDataRelay.value?.name, "홍길동")
    }

    func test_getUser_실패시_userDataRelay_미변경() async {
        // Given
        mockUserUseCase.getUserResult = .failure(.serverError(401))

        // When
        await sut.getUser()

        // Then
        XCTAssertNil(sut.userDataRelay.value)
    }

    func test_getUser_실패시_에러메시지_저장() async {
        // Given
        let error = NetworkError.serverError(401)
        mockUserUseCase.getUserResult = .failure(error)

        // When
        await sut.getUser()

        // Then
        XCTAssertNotNil(sut.toastMessageRelay.value)
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

    // MARK: - getMonthlyDiets: 결과 검증

    func test_getMonthlyDiets_성공시_monthDataCache_업데이트() async {
        // Given
        let diet = DietData.fixture(consumeDate: "2026-03-12", mealType: .breakfast)
        mockDietUseCase.getMonthlyDietResult = .success([diet])

        // When
        await sut.getMonthlyDiets(year: 2026, month: 3)

        // Then: "2026-3" 키로 캐시 저장
        XCTAssertNotNil(sut.monthDataCache.value["2026-3"])
        XCTAssertNotNil(sut.monthDataCache.value["2026-3"]?["2026-03-12"])
    }

    func test_getMonthlyDiets_성공시_ateDateRelay_업데이트() async {
        // Given
        let diet = DietData.fixture(consumeDate: "2026-03-12", mealType: .breakfast)
        mockDietUseCase.getMonthlyDietResult = .success([diet])

        // When
        await sut.getMonthlyDiets(year: 2026, month: 3)

        // Then: 식단이 있는 날짜가 ateDateRelay에 추가됨
        XCTAssertFalse(sut.ateDateRelay.value.isEmpty)
    }

    func test_getMonthlyDiets_성공시_selectedDayDataCache_업데이트() async {
        // Given: selectedDate를 2026-03-12로 설정
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026; components.month = 3; components.day = 12
        let targetDate = calendar.date(from: components)!
        sut.selectedDate.accept(targetDate)

        let diet = DietData.fixture(consumeDate: "2026-03-12", mealType: .breakfast)
        mockDietUseCase.getMonthlyDietResult = .success([diet])

        // When
        await sut.getMonthlyDiets(year: 2026, month: 3)

        // Then
        XCTAssertFalse(sut.selectedDayDataCache.value.isEmpty)
    }

    func test_getMonthlyDiets_빈배열_성공시_캐시_비어있음() async {
        // Given
        mockDietUseCase.getMonthlyDietResult = .success([])

        // When
        await sut.getMonthlyDiets(year: 2026, month: 3)

        // Then: 키는 존재하지만 하위 딕셔너리가 비어있음
        XCTAssertNotNil(sut.monthDataCache.value["2026-3"])
        XCTAssertTrue(sut.monthDataCache.value["2026-3"]!.isEmpty)
    }

    func test_getMonthlyDiets_실패시_에러메시지_저장() async {
        // Given
        let error = NetworkError.serverError(500)
        mockDietUseCase.getMonthlyDietResult = .failure(error)

        // When
        await sut.getMonthlyDiets(year: 2026, month: 3)

        // Then
        XCTAssertNotNil(sut.toastMessageRelay.value)
    }

    func test_getMonthlyDiets_실패시_캐시_미변경() async {
        // Given
        mockDietUseCase.getMonthlyDietResult = .failure(.serverError(500))
        let beforeCache = sut.monthDataCache.value

        // When
        await sut.getMonthlyDiets(year: 2026, month: 3)

        // Then
        XCTAssertEqual(sut.monthDataCache.value.count, beforeCache.count)
    }

    func test_getMonthlyDiets_로딩흐름_true후_false() async {
        // Given
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.getMonthlyDiets(year: 2026, month: 3)

        // Then: [false(초기), true(시작), false(완료)]
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    // MARK: - setBinding: selectedDate → selectedDayDataCache (캐시 히트)

    func test_selectedDate_변경시_캐시있으면_selectedDayDataCache_업데이트() {
        // Given: 캐시를 직접 주입
        let diet = DietData.fixture(consumeDate: "2026-03-15", mealType: .breakfast)
        sut.monthDataCache.accept(["2026-3": ["2026-03-15": [diet]]])

        // When: 캐시된 달의 다른 날로 이동
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026; components.month = 3; components.day = 15
        let march15 = calendar.date(from: components)!
        sut.selectedDate.accept(march15)

        // Then
        XCTAssertEqual(sut.selectedDayDataCache.value.count, 1)
        XCTAssertEqual(sut.selectedDayDataCache.value.first?.mealType, .breakfast)
    }

    func test_selectedDate_변경시_해당날짜_데이터없으면_빈배열() {
        // Given: 3월 캐시가 있지만 16일 데이터는 없음
        let diet = DietData.fixture(consumeDate: "2026-03-15", mealType: .breakfast)
        sut.monthDataCache.accept(["2026-3": ["2026-03-15": [diet]]])

        // When: 데이터 없는 16일로 이동
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026; components.month = 3; components.day = 16
        let march16 = calendar.date(from: components)!
        sut.selectedDate.accept(march16)

        // Then
        XCTAssertTrue(sut.selectedDayDataCache.value.isEmpty)
    }

    // MARK: - 여러 날짜 캐시 누적

    func test_getMonthlyDiets_연속호출시_캐시_누적() async {
        // Given
        let march = DietData.fixture(consumeDate: "2026-03-12", mealType: .breakfast)
        let april = DietData.fixture(consumeDate: "2026-04-01", mealType: .lunch)

        mockDietUseCase.getMonthlyDietResult = .success([march])
        await sut.getMonthlyDiets(year: 2026, month: 3)

        mockDietUseCase.getMonthlyDietResult = .success([april])
        await sut.getMonthlyDiets(year: 2026, month: 4)

        // Then: 두 달 모두 캐시에 존재
        XCTAssertNotNil(sut.monthDataCache.value["2026-3"])
        XCTAssertNotNil(sut.monthDataCache.value["2026-4"])
    }
}
