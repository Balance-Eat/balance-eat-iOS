//
//  HomeViewModelTests.swift
//  BalanceEatTests
//

@testable import BalanceEat
import XCTest
import RxSwift

@MainActor
final class HomeViewModelTests: XCTestCase {

    private var sut: HomeViewModel!
    private var mockUserUseCase: MockUserUseCase!
    private var mockDietUseCase: MockDietUseCase!
    private var disposeBag: DisposeBag!

    override func setUp() async throws {
        try await super.setUp()
        mockUserUseCase = MockUserUseCase()
        mockDietUseCase = MockDietUseCase()
        disposeBag = DisposeBag()
        sut = HomeViewModel(userUseCase: mockUserUseCase, dietUseCase: mockDietUseCase)
    }

    override func tearDown() async throws {
        sut = nil
        mockUserUseCase = nil
        mockDietUseCase = nil
        disposeBag = nil
        try await super.tearDown()
    }

    // MARK: - getUser: 결과 검증

    func test_getUser_성공시_userResponseRelay_업데이트() async {
        // Given
        let expectedUser = UserData.fixture(name: "홍길동")
        mockUserUseCase.getUserResult = .success(expectedUser)

        // When
        await sut.getUser()

        // Then
        XCTAssertEqual(sut.userResponseRelay.value?.name, "홍길동")
    }

    func test_getUser_성공시_userId_저장() async {
        // Given
        let user = UserData.fixture(id: 99)
        mockUserUseCase.getUserResult = .success(user)

        // When
        await sut.getUser()

        // Then: saveUserId가 성공적으로 호출되어야 함 (에러 없음)
        XCTAssertNil(sut.toastMessageRelay.value)
    }

    func test_getUser_실패시_에러메시지_저장() async {
        // Given
        let error = NetworkError.serverError(500)
        mockUserUseCase.getUserResult = .failure(error)

        // When
        await sut.getUser()

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, "사용자 정보 불러오기 실패: \(error.description)")
    }

    func test_getUser_실패시_userResponseRelay_미변경() async {
        // Given
        mockUserUseCase.getUserResult = .failure(.serverError(500))

        // When
        await sut.getUser()

        // Then
        XCTAssertNil(sut.userResponseRelay.value)
    }

    // MARK: - getUser: 로딩 흐름

    func test_getUser_성공시_로딩흐름_true후_false() async {
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

    func test_getUser_실패시_로딩흐름_true후_false() async {
        // Given
        mockUserUseCase.getUserResult = .failure(.serverError(500))
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.getUser()

        // Then
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    // MARK: - setBinding: userResponseRelay 변경 반응

    func test_setBinding_user_변경시_userName_업데이트() {
        // When
        sut.userResponseRelay.accept(UserData.fixture(name: "김철수"))

        // Then
        XCTAssertEqual(sut.userNameRelay.value, "김철수")
    }

    func test_setBinding_user_nil시_userName_빈문자열() {
        // Given: 먼저 값을 설정
        sut.userResponseRelay.accept(UserData.fixture(name: "김철수"))

        // When
        sut.userResponseRelay.accept(nil)

        // Then
        XCTAssertEqual(sut.userNameRelay.value, "")
    }

    func test_setBinding_user_변경시_nowBodyStatus_업데이트() {
        // Given
        let user = UserData.fixture(weight: 75.0, smi: 30.0, fatPercentage: 20.0)

        // When
        sut.userResponseRelay.accept(user)

        // Then: (weight, smi, fatPercentage)
        XCTAssertEqual(sut.userNowBodyStatusRelay.value.0, 75.0)
        XCTAssertEqual(sut.userNowBodyStatusRelay.value.1, 30.0)
        XCTAssertEqual(sut.userNowBodyStatusRelay.value.2, 20.0)
    }

    func test_setBinding_user_변경시_targetBodyStatus_업데이트() {
        // Given
        let user = UserData.fixture(targetWeight: 68.0)

        // When
        sut.userResponseRelay.accept(user)

        // Then
        XCTAssertEqual(sut.userTargetBodyStatusRelay.value.0, 68.0)
    }

    // MARK: - getDailyDiet: 결과 검증

    func test_getDailyDiet_userId_없을때_UseCase_미호출() async {
        // Given: userResponseRelay가 nil (초기 상태)
        XCTAssertNil(sut.userResponseRelay.value)

        // When
        await sut.getDailyDiet()

        // Then: userId를 가져올 수 없으므로 UseCase 호출 안 함
        XCTAssertNil(sut.dietResponseRelay.value)
    }

    func test_getDailyDiet_성공시_dietResponseRelay_업데이트() async {
        // Given
        sut.userResponseRelay.accept(UserData.fixture(id: 1))
        let dietData = DietData.fixture(mealType: .breakfast)
        mockDietUseCase.getDailyDietResult = .success([dietData])

        // When
        await sut.getDailyDiet()

        // Then
        XCTAssertEqual(sut.dietResponseRelay.value?.count, 1)
    }

    func test_getDailyDiet_성공시_빈배열도_정상반영() async {
        // Given
        sut.userResponseRelay.accept(UserData.fixture())
        mockDietUseCase.getDailyDietResult = .success([])

        // When
        await sut.getDailyDiet()

        // Then
        XCTAssertEqual(sut.dietResponseRelay.value?.count, 0)
    }

    func test_getDailyDiet_실패시_에러메시지_저장() async {
        // Given
        sut.userResponseRelay.accept(UserData.fixture())
        let error = NetworkError.serverError(500)
        mockDietUseCase.getDailyDietResult = .failure(error)

        // When
        await sut.getDailyDiet()

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, "일일 식단 정보 불러오기 실패: \(error.description)")
    }

    func test_getDailyDiet_로딩흐름_true후_false() async {
        // Given
        sut.userResponseRelay.accept(UserData.fixture())
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.getDailyDiet()

        // Then
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    // MARK: - formatConsumedTime

    func test_formatConsumedTime_올바른_시간_반환() {
        // Given: ISO8601 형식 (Asia/Seoul 기준)
        let dateString = "2026-03-12T08:30:00.000+09:00"

        // When
        let result = sut.formatConsumedTime(dateString)

        // Then
        XCTAssertEqual(result, "08:30")
    }

    func test_formatConsumedTime_잘못된_형식_빈문자열_반환() {
        // Given
        let invalidString = "not-a-date"

        // When
        let result = sut.formatConsumedTime(invalidString)

        // Then
        XCTAssertEqual(result, "")
    }
}
