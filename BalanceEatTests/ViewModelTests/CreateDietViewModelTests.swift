//
//  CreateDietViewModelTests.swift
//  BalanceEatTests
//

@testable import BalanceEat
import XCTest
import RxSwift

@MainActor
final class CreateDietViewModelTests: XCTestCase {

    private var sut: CreateDietViewModel!
    private var mockDietUseCase: MockDietUseCase!
    private var mockUserUseCase: MockUserUseCase!
    private var disposeBag: DisposeBag!

    override func setUp() async throws {
        try await super.setUp()
        mockDietUseCase = MockDietUseCase()
        mockUserUseCase = MockUserUseCase()
        disposeBag = DisposeBag()
        sut = makeSUT()
    }

    override func tearDown() async throws {
        sut = nil
        mockDietUseCase = nil
        mockUserUseCase = nil
        disposeBag = nil
        try await super.tearDown()
    }

    // MARK: - Helpers

    private func makeSUT(dietDatas: [DietData] = [], date: Date = Date()) -> CreateDietViewModel {
        CreateDietViewModel(
            dietUseCase: mockDietUseCase,
            userUseCase: mockUserUseCase,
            dietDatas: dietDatas,
            date: date
        )
    }

    // MARK: - createDiet: 결과 검증

    func test_createDiet_성공시_saveDietSuccessRelay_발행() async {
        // Given
        var emittedCount = 0
        sut.saveDietSuccessRelay
            .subscribe(onNext: { emittedCount += 1 })
            .disposed(by: disposeBag)

        // When
        await sut.createDiet(mealType: .breakfast, consumedAt: "2026-03-12T08:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(emittedCount, 1)
    }

    func test_createDiet_성공시_토스트메시지_저장완료() async {
        // When
        await sut.createDiet(mealType: .breakfast, consumedAt: "2026-03-12T08:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, "식단 저장을 완료했습니다.")
    }

    func test_createDiet_실패시_saveDietSuccessRelay_미발행() async {
        // Given
        mockDietUseCase.createDietResult = .failure(.serverError(500))
        var emittedCount = 0
        sut.saveDietSuccessRelay
            .subscribe(onNext: { emittedCount += 1 })
            .disposed(by: disposeBag)

        // When
        await sut.createDiet(mealType: .breakfast, consumedAt: "2026-03-12T08:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(emittedCount, 0)
    }

    func test_createDiet_실패시_에러메시지_저장() async {
        // Given
        let error = NetworkError.serverError(500)
        mockDietUseCase.createDietResult = .failure(error)

        // When
        await sut.createDiet(mealType: .breakfast, consumedAt: "2026-03-12T08:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, error.description)
    }

    // MARK: - createDiet: 로딩 흐름 검증

    func test_createDiet_성공시_로딩흐름_true후_false() async {
        // Given: BehaviorRelay는 구독 즉시 현재값(false)을 방출하므로 [false, true, false] 기대
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.createDiet(mealType: .breakfast, consumedAt: "2026-03-12T08:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    func test_createDiet_실패시_로딩흐름_true후_false() async {
        // Given
        mockDietUseCase.createDietResult = .failure(.serverError(500))
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.createDiet(mealType: .breakfast, consumedAt: "2026-03-12T08:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    // MARK: - createDiet: 호출 횟수 및 인자 검증

    func test_createDiet_UseCase_정확히_1회_호출() async {
        // When
        await sut.createDiet(mealType: .breakfast, consumedAt: "2026-03-12T08:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(mockDietUseCase.createDietCallCount, 1)
    }

    func test_createDiet_UseCase에_올바른_인자_전달() async {
        // Given
        let expectedMealType = MealType.lunch
        let expectedConsumedAt = "2026-03-12T12:00:00"
        let expectedUserId = "42"
        let expectedFoods = [DietFoodRequest(foodId: 1, intake: 100)]

        // When
        await sut.createDiet(
            mealType: expectedMealType,
            consumedAt: expectedConsumedAt,
            dietFoods: expectedFoods,
            userId: expectedUserId
        )

        // Then
        XCTAssertEqual(mockDietUseCase.capturedCreateMealType, expectedMealType)
        XCTAssertEqual(mockDietUseCase.capturedCreateConsumedAt, expectedConsumedAt)
        XCTAssertEqual(mockDietUseCase.capturedCreateUserId, expectedUserId)
        XCTAssertEqual(mockDietUseCase.capturedCreateDietFoods?.count, 1)
        XCTAssertEqual(mockDietUseCase.capturedCreateDietFoods?.first?.foodId, 1)
    }

    func test_createDiet_연속호출시_매번_UseCase_호출() async {
        // When
        await sut.createDiet(mealType: .breakfast, consumedAt: "2026-03-12T08:00:00", dietFoods: [], userId: "1")
        await sut.createDiet(mealType: .lunch, consumedAt: "2026-03-12T12:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(mockDietUseCase.createDietCallCount, 2)
    }

    // MARK: - updateDiet

    func test_updateDiet_성공시_saveDietSuccessRelay_발행() async {
        // Given
        var emittedCount = 0
        sut.saveDietSuccessRelay
            .subscribe(onNext: { emittedCount += 1 })
            .disposed(by: disposeBag)

        // When
        await sut.updateDiet(dietId: 1, mealType: .lunch, consumedAt: "2026-03-12T12:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(emittedCount, 1)
    }

    func test_updateDiet_성공시_토스트메시지_수정완료() async {
        // When
        await sut.updateDiet(dietId: 1, mealType: .lunch, consumedAt: "2026-03-12T12:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, "식단 수정을 완료했습니다.")
    }

    func test_updateDiet_실패시_에러메시지_저장() async {
        // Given
        let error = NetworkError.serverError(404)
        mockDietUseCase.updateDietResult = .failure(error)

        // When
        await sut.updateDiet(dietId: 1, mealType: .lunch, consumedAt: "2026-03-12T12:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, error.description)
    }

    func test_updateDiet_UseCase에_올바른_dietId_전달() async {
        // Given
        let expectedDietId = 99

        // When
        await sut.updateDiet(dietId: expectedDietId, mealType: .dinner, consumedAt: "2026-03-12T19:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(mockDietUseCase.capturedUpdateDietId, expectedDietId)
        XCTAssertEqual(mockDietUseCase.capturedUpdateMealType, .dinner)
    }

    func test_updateDiet_로딩흐름_true후_false() async {
        // Given
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.updateDiet(dietId: 1, mealType: .lunch, consumedAt: "2026-03-12T12:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    // MARK: - deleteDiet

    func test_deleteDiet_성공시_currentFoodsRelay_nil() async {
        // Given
        sut = makeSUT(dietDatas: [.fixture(mealType: .breakfast, items: [.fixture()])])
        mockDietUseCase.deleteDietResult = .success(())

        // When
        await sut.deleteDiet(dietId: 1, userId: "1")

        // Then
        XCTAssertNil(sut.currentFoodsRelay.value)
    }

    func test_deleteDiet_성공시_deleteButton_비활성화() async {
        // Given
        sut = makeSUT(dietDatas: [.fixture(mealType: .breakfast, items: [.fixture()])])

        // When
        await sut.deleteDiet(dietId: 1, userId: "1")

        // Then
        XCTAssertFalse(sut.deleteButtonIsEnabledRelay.value)
    }

    func test_deleteDiet_성공시_토스트메시지_삭제완료() async {
        // When
        await sut.deleteDiet(dietId: 1, userId: "1")

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, "식단 삭제를 완료했습니다.")
    }

    func test_deleteDiet_실패시_에러메시지_저장() async {
        // Given
        let error = NetworkError.serverError(500)
        mockDietUseCase.deleteDietResult = .failure(error)

        // When
        await sut.deleteDiet(dietId: 1, userId: "1")

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, error.description)
    }

    func test_deleteDiet_UseCase에_올바른_인자_전달() async {
        // Given
        let expectedDietId = 77
        let expectedUserId = "99"

        // When
        await sut.deleteDiet(dietId: expectedDietId, userId: expectedUserId)

        // Then
        XCTAssertEqual(mockDietUseCase.capturedDeleteDietId, expectedDietId)
        XCTAssertEqual(mockDietUseCase.capturedDeleteUserId, expectedUserId)
    }

    func test_deleteDiet_로딩흐름_true후_false() async {
        // Given
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.deleteDiet(dietId: 1, userId: "1")

        // Then
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    // MARK: - deleteFood

    func test_deleteFood_해당음식_목록에서_제거() {
        // Given
        let food = DietFoodData.fixture(id: 1)
        sut = makeSUT(dietDatas: [.fixture(mealType: .breakfast, items: [food])])

        // When
        sut.deleteFood(food: food)

        // Then
        XCTAssertTrue(sut.currentFoodsRelay.value?.items.isEmpty == true)
    }

    func test_deleteFood_여러음식_중_하나만_제거() {
        // Given
        let food1 = DietFoodData.fixture(id: 1, name: "닭가슴살")
        let food2 = DietFoodData.fixture(id: 2, name: "현미밥")
        sut = makeSUT(dietDatas: [.fixture(mealType: .breakfast, items: [food1, food2])])

        // When
        sut.deleteFood(food: food1)

        // Then
        XCTAssertEqual(sut.currentFoodsRelay.value?.items.count, 1)
        XCTAssertEqual(sut.currentFoodsRelay.value?.items.first?.id, food2.id)
    }

    func test_deleteFood_없는음식_삭제시_변화없음() {
        // Given
        let existing = DietFoodData.fixture(id: 1)
        let nonExisting = DietFoodData.fixture(id: 99, name: "없는음식")
        sut = makeSUT(dietDatas: [.fixture(mealType: .breakfast, items: [existing])])

        // When
        sut.deleteFood(food: nonExisting)

        // Then
        XCTAssertEqual(sut.currentFoodsRelay.value?.items.count, 1)
    }

    func test_deleteFood_UseCase_호출하지_않음() {
        // Given
        let food = DietFoodData.fixture(id: 1)
        sut = makeSUT(dietDatas: [.fixture(mealType: .breakfast, items: [food])])

        // When
        sut.deleteFood(food: food)

        // Then: deleteFood는 로컬 처리이므로 UseCase 호출 없어야 함
        XCTAssertEqual(mockDietUseCase.deleteDietCallCount, 0)
    }

    // MARK: - setBinding: mealTime 변경

    func test_mealTime_변경시_currentFoods_해당_식사로_업데이트() {
        // Given
        let breakfastDiet = DietData.fixture(id: 1, mealType: .breakfast, items: [.fixture(id: 1, name: "아침음식")])
        let lunchDiet = DietData.fixture(id: 2, mealType: .lunch, items: [.fixture(id: 2, name: "점심음식")])
        sut = makeSUT(dietDatas: [breakfastDiet, lunchDiet])

        // When
        sut.mealTimeRelay.accept(.lunch)

        // Then
        XCTAssertEqual(sut.currentFoodsRelay.value?.items.first?.name, "점심음식")
    }

    func test_mealTime_변경시_해당식사_없으면_currentFoods_nil() {
        // Given: 아침 식단만 있음
        sut = makeSUT(dietDatas: [.fixture(mealType: .breakfast, items: [.fixture()])])

        // When: 저녁으로 변경
        sut.mealTimeRelay.accept(.dinner)

        // Then
        XCTAssertNil(sut.currentFoodsRelay.value)
    }

    func test_mealTime_변경시_deleteButton_활성화_여부_업데이트() {
        // Given: 점심만 있음
        let lunchDiet = DietData.fixture(id: 2, mealType: .lunch, items: [.fixture()])
        sut = makeSUT(dietDatas: [lunchDiet])
        XCTAssertFalse(sut.deleteButtonIsEnabledRelay.value) // 초기: 아침 선택, 데이터 없음

        // When: 점심으로 변경
        sut.mealTimeRelay.accept(.lunch)

        // Then: 점심 데이터 있으므로 활성화
        XCTAssertTrue(sut.deleteButtonIsEnabledRelay.value)
    }

    // MARK: - setBinding: dataChanged 감지

    func test_초기상태_아이템없으면_dataChanged_false() {
        // Given: items가 비어 있으면 intakeRelay가 빈 상태여도 변경 없음
        sut = makeSUT(dietDatas: [.fixture(mealType: .breakfast, items: [])])

        // Then
        XCTAssertFalse(sut.dataChangedRelay.value)
    }

    func test_초기상태_아이템있으면_dataChanged_true() {
        // Given: intakeRelay는 초기에 빈 딕셔너리이므로
        //        item.intake(100) != intake[id](nil) → isIntakeCorrect = false → true
        sut = makeSUT(dietDatas: [.fixture(mealType: .breakfast, items: [.fixture()])])

        // Then
        XCTAssertTrue(sut.dataChangedRelay.value)
    }

    func test_음식삭제시_originalData와_달라져_dataChanged_true() {
        // Given
        let food = DietFoodData.fixture(id: 1)
        sut = makeSUT(dietDatas: [.fixture(mealType: .breakfast, items: [food])])

        // When
        sut.deleteFood(food: food)

        // Then: original에는 food가 있었지만 현재는 없으므로 변경됨
        XCTAssertTrue(sut.dataChangedRelay.value)
    }

    // MARK: - getUserId

    func test_getUserId_성공시_userId_문자열_반환() {
        // Given
        mockUserUseCase.getUserIdResult = .success(42)

        // Then
        XCTAssertEqual(sut.getUserId(), "42")
    }

    func test_getUserId_실패시_nil_반환() {
        // Given
        mockUserUseCase.getUserIdResult = .failure(.readError("userId 없음"))

        // Then
        XCTAssertNil(sut.getUserId())
    }

    func test_getUserId_실패시_에러메시지_저장() {
        // Given
        mockUserUseCase.getUserIdResult = .failure(.readError("userId 없음"))

        // When
        _ = sut.getUserId()

        // Then
        XCTAssertNotNil(sut.toastMessageRelay.value)
    }
}
