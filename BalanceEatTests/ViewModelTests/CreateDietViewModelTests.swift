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
        sut = CreateDietViewModel(
            dietUseCase: mockDietUseCase,
            userUseCase: mockUserUseCase,
            dietDatas: [],
            date: Date()
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockDietUseCase = nil
        mockUserUseCase = nil
        disposeBag = nil
        try await super.tearDown()
    }

    // MARK: - createDiet

    func test_createDiet_성공시_saveDietSuccessRelay_발행() async {
        // Given
        mockDietUseCase.createDietResult = .success(())
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
        // Given
        mockDietUseCase.createDietResult = .success(())

        // When
        await sut.createDiet(mealType: .breakfast, consumedAt: "2026-03-12T08:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, "식단 저장을 완료했습니다.")
    }

    func test_createDiet_성공시_로딩상태_false() async {
        // Given
        mockDietUseCase.createDietResult = .success(())

        // When
        await sut.createDiet(mealType: .breakfast, consumedAt: "2026-03-12T08:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertFalse(sut.loadingRelay.value)
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

    func test_createDiet_실패시_로딩상태_false() async {
        // Given
        mockDietUseCase.createDietResult = .failure(.serverError(500))

        // When
        await sut.createDiet(mealType: .breakfast, consumedAt: "2026-03-12T08:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertFalse(sut.loadingRelay.value)
    }

    // MARK: - updateDiet

    func test_updateDiet_성공시_saveDietSuccessRelay_발행() async {
        // Given
        mockDietUseCase.updateDietResult = .success(())
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
        // Given
        mockDietUseCase.updateDietResult = .success(())

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

    func test_updateDiet_실패시_로딩상태_false() async {
        // Given
        mockDietUseCase.updateDietResult = .failure(.serverError(404))

        // When
        await sut.updateDiet(dietId: 1, mealType: .lunch, consumedAt: "2026-03-12T12:00:00", dietFoods: [], userId: "1")

        // Then
        XCTAssertFalse(sut.loadingRelay.value)
    }

    // MARK: - deleteDiet

    func test_deleteDiet_성공시_currentFoodsRelay_nil() async {
        // Given
        let food = DietFoodData.fixture()
        let diet = DietData.fixture(mealType: .breakfast, items: [food])
        sut = CreateDietViewModel(
            dietUseCase: mockDietUseCase,
            userUseCase: mockUserUseCase,
            dietDatas: [diet],
            date: Date()
        )
        mockDietUseCase.deleteDietResult = .success(())

        // When
        await sut.deleteDiet(dietId: diet.id, userId: "1")

        // Then
        XCTAssertNil(sut.currentFoodsRelay.value)
    }

    func test_deleteDiet_성공시_deleteButton_비활성화() async {
        // Given
        let diet = DietData.fixture(mealType: .breakfast, items: [.fixture()])
        sut = CreateDietViewModel(
            dietUseCase: mockDietUseCase,
            userUseCase: mockUserUseCase,
            dietDatas: [diet],
            date: Date()
        )
        mockDietUseCase.deleteDietResult = .success(())

        // When
        await sut.deleteDiet(dietId: diet.id, userId: "1")

        // Then
        XCTAssertFalse(sut.deleteButtonIsEnabledRelay.value)
    }

    func test_deleteDiet_성공시_토스트메시지_삭제완료() async {
        // Given
        mockDietUseCase.deleteDietResult = .success(())

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

    func test_deleteDiet_실패시_로딩상태_false() async {
        // Given
        mockDietUseCase.deleteDietResult = .failure(.serverError(500))

        // When
        await sut.deleteDiet(dietId: 1, userId: "1")

        // Then
        XCTAssertFalse(sut.loadingRelay.value)
    }

    // MARK: - deleteFood

    func test_deleteFood_해당음식_목록에서_제거() {
        // Given
        let food = DietFoodData.fixture(id: 1)
        let diet = DietData.fixture(mealType: .breakfast, items: [food])
        sut = CreateDietViewModel(
            dietUseCase: mockDietUseCase,
            userUseCase: mockUserUseCase,
            dietDatas: [diet],
            date: Date()
        )

        // When
        sut.deleteFood(food: food)

        // Then
        XCTAssertTrue(sut.currentFoodsRelay.value?.items.isEmpty == true)
    }

    func test_deleteFood_여러음식_중_하나만_제거() {
        // Given
        let food1 = DietFoodData.fixture(id: 1, name: "닭가슴살")
        let food2 = DietFoodData.fixture(id: 2, name: "현미밥")
        let diet = DietData.fixture(mealType: .breakfast, items: [food1, food2])
        sut = CreateDietViewModel(
            dietUseCase: mockDietUseCase,
            userUseCase: mockUserUseCase,
            dietDatas: [diet],
            date: Date()
        )

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
        let diet = DietData.fixture(mealType: .breakfast, items: [existing])
        sut = CreateDietViewModel(
            dietUseCase: mockDietUseCase,
            userUseCase: mockUserUseCase,
            dietDatas: [diet],
            date: Date()
        )

        // When
        sut.deleteFood(food: nonExisting)

        // Then
        XCTAssertEqual(sut.currentFoodsRelay.value?.items.count, 1)
    }

    // MARK: - getUserId

    func test_getUserId_성공시_userId_문자열_반환() {
        // Given
        mockUserUseCase.getUserIdResult = .success(42)

        // When
        let result = sut.getUserId()

        // Then
        XCTAssertEqual(result, "42")
    }

    func test_getUserId_실패시_빈문자열_반환() {
        // Given
        mockUserUseCase.getUserIdResult = .failure(.readError("userId 없음"))

        // When
        let result = sut.getUserId()

        // Then
        XCTAssertEqual(result, "")
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
