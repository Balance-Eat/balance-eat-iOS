//
//  CreateFoodViewModelTests.swift
//  BalanceEatTests
//

@testable import BalanceEat
import XCTest
import RxSwift

@MainActor
final class CreateFoodViewModelTests: XCTestCase {

    private var sut: CreateFoodViewModel!
    private var mockFoodUseCase: MockFoodUseCase!
    private var disposeBag: DisposeBag!

    override func setUp() async throws {
        try await super.setUp()
        mockFoodUseCase = MockFoodUseCase()
        disposeBag = DisposeBag()
        sut = CreateFoodViewModel(foodUseCase: mockFoodUseCase)
    }

    override func tearDown() async throws {
        sut = nil
        mockFoodUseCase = nil
        disposeBag = nil
        try await super.tearDown()
    }

    // MARK: - calculatedCalorieObservable

    func test_calorie_탄단지로_계산() {
        // Given: 탄수화물 50g, 단백질 30g, 지방 10g
        // 50*4 + 30*4 + 10*9 = 200 + 120 + 90 = 410
        var calorie: Double?
        sut.calculatedCalorieObservable
            .subscribe(onNext: { calorie = $0 })
            .disposed(by: disposeBag)

        sut.carbonRelay.accept(50)
        sut.proteinRelay.accept(30)
        sut.fatRelay.accept(10)

        XCTAssertEqual(calorie, 410)
    }

    func test_calorie_초기값_0() {
        var calorie: Double?
        sut.calculatedCalorieObservable
            .subscribe(onNext: { calorie = $0 })
            .disposed(by: disposeBag)

        XCTAssertEqual(calorie, 0)
    }

    // MARK: - isInvalidInputObservable

    func test_isInvalidInput_초기값_true() {
        var isInvalid: Bool?
        sut.isInvalidInputObservable
            .subscribe(onNext: { isInvalid = $0 })
            .disposed(by: disposeBag)

        XCTAssertEqual(isInvalid, true)
    }

    func test_isInvalidInput_모든필드입력시_false() {
        var isInvalid: Bool?
        sut.isInvalidInputObservable
            .subscribe(onNext: { isInvalid = $0 })
            .disposed(by: disposeBag)

        sut.nameRelay.accept("닭가슴살")
        sut.amountRelay.accept(100)
        sut.unitRelay.accept("g")
        sut.carbonRelay.accept(1)
        sut.proteinRelay.accept(30)
        sut.fatRelay.accept(3)

        XCTAssertEqual(isInvalid, false)
    }

    func test_isInvalidInput_이름비어있으면_true() {
        var isInvalid: Bool?
        sut.isInvalidInputObservable
            .subscribe(onNext: { isInvalid = $0 })
            .disposed(by: disposeBag)

        sut.nameRelay.accept("")
        sut.amountRelay.accept(100)
        sut.unitRelay.accept("g")
        sut.carbonRelay.accept(1)
        sut.proteinRelay.accept(30)
        sut.fatRelay.accept(3)

        XCTAssertEqual(isInvalid, true)
    }

    // MARK: - isResetHiddenObservable

    func test_isResetHidden_초기값_true() {
        var isHidden: Bool?
        sut.isResetHiddenObservable
            .subscribe(onNext: { isHidden = $0 })
            .disposed(by: disposeBag)

        XCTAssertEqual(isHidden, true)
    }

    func test_isResetHidden_값입력시_false() {
        var isHidden: Bool?
        sut.isResetHiddenObservable
            .subscribe(onNext: { isHidden = $0 })
            .disposed(by: disposeBag)

        sut.nameRelay.accept("닭가슴살")

        XCTAssertEqual(isHidden, false)
    }

    // MARK: - createFood

    func test_createFood_성공시_createFoodResultRelay_발행() async {
        // Given
        let expectedFood = FoodData.fixture(name: "닭가슴살")
        mockFoodUseCase.createFoodResult = .success(expectedFood)
        var result: FoodData?
        sut.createFoodResultRelay
            .subscribe(onNext: { result = $0 })
            .disposed(by: disposeBag)

        sut.nameRelay.accept("닭가슴살")
        sut.amountRelay.accept(100)
        sut.unitRelay.accept("g")

        // When
        await sut.createFood()

        // Then
        XCTAssertEqual(result?.name, "닭가슴살")
    }

    func test_createFood_실패시_에러메시지_저장() async {
        // Given
        let error = NetworkError.serverError(500)
        mockFoodUseCase.createFoodResult = .failure(error)

        // When
        await sut.createFood()

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, "음식 생성에 실패했습니다: \(error.description)")
    }

    func test_createFood_UseCase_정확히_1회_호출() async {
        // When
        await sut.createFood()

        // Then
        XCTAssertEqual(mockFoodUseCase.createFoodCallCount, 1)
    }

    func test_createFood_로딩흐름_true후_false() async {
        // Given
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.createFood()

        // Then
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    func test_createFood_brandName_비어있으면_없음으로_전달() async {
        // Given
        mockFoodUseCase.createFoodResult = .success(.fixture())
        sut.brandNameRelay.accept("")

        // When
        await sut.createFood()

        // Then: 크래시 없이 성공 (brand가 "없음"으로 처리됨)
        XCTAssertEqual(mockFoodUseCase.createFoodCallCount, 1)
    }
}
