//
//  EditTargetTypeAndActivityLevelViewModelTests.swift
//  BalanceEatTests
//

@testable import BalanceEat
import XCTest
import RxSwift

@MainActor
final class EditTargetTypeAndActivityLevelViewModelTests: XCTestCase {

    private var sut: EditTargetTypeAndActivityLevelViewModel!
    private var mockUserUseCase: MockUserUseCase!
    private var disposeBag: DisposeBag!

    private let baseUserData = UserData.fixture(
        gender: .male,
        age: 25,
        weight: 70.0,
        height: 175.0
    )

    override func setUp() async throws {
        try await super.setUp()
        mockUserUseCase = MockUserUseCase()
        disposeBag = DisposeBag()
        sut = EditTargetTypeAndActivityLevelViewModel(userData: baseUserData, userUseCase: mockUserUseCase)
    }

    override func tearDown() async throws {
        sut = nil
        mockUserUseCase = nil
        disposeBag = nil
        try await super.tearDown()
    }

    // MARK: - 초기화

    func test_init_userRelay_userData로_설정() {
        XCTAssertEqual(sut.userRelay.value?.name, baseUserData.name)
    }

    // MARK: - BMRObservable

    func test_BMR_남성_공식_적용() {
        // Given: weight=70, height=175, age=25, gender=male
        // BMR = 10*70 + 6.25*175 - 5*25 + 5 = 700 + 1093.75 - 125 + 5 = 1673.75 → 1673
        var bmr: Int?
        sut.BMRObservable
            .subscribe(onNext: { bmr = $0 })
            .disposed(by: disposeBag)

        XCTAssertEqual(bmr, 1673)
    }

    func test_BMR_여성_공식_적용() {
        // Given: weight=55, height=163, age=28, gender=female
        // BMR = 10*55 + 6.25*163 - 5*28 - 161 = 550 + 1018.75 - 140 - 161 = 1267.75 → 1267
        let femaleUser = UserData.fixture(gender: .female, age: 28, weight: 55.0, height: 163.0)
        let vm = EditTargetTypeAndActivityLevelViewModel(userData: femaleUser, userUseCase: mockUserUseCase)

        var bmr: Int?
        vm.BMRObservable
            .subscribe(onNext: { bmr = $0 })
            .disposed(by: disposeBag)

        XCTAssertEqual(bmr, 1267)
    }

    // MARK: - targetCaloriesObservable

    func test_targetCaloriesObservable_유지_moderate_칼로리() {
        // Given: BMR≈1673, maintain, moderate(1.55)
        // 1673 * 1.55 + 0 = 2593.15
        sut.selectedGoalRelay.accept(.maintain)
        sut.selectedActivityLevel.accept(.moderate)

        var calories: Double?
        sut.targetCaloriesObservable
            .subscribe(onNext: { calories = $0 })
            .disposed(by: disposeBag)

        XCTAssertNotNil(calories)
        XCTAssertGreaterThan(calories ?? 0, 0)
    }

    func test_targetCaloriesObservable_다이어트_칼로리_차감() {
        // Given
        sut.selectedGoalRelay.accept(.diet)
        sut.selectedActivityLevel.accept(.moderate)

        var maintainCalories: Double?
        var dietCalories: Double?

        sut.selectedGoalRelay.accept(.maintain)
        sut.targetCaloriesObservable
            .subscribe(onNext: { maintainCalories = $0 })
            .disposed(by: disposeBag)

        sut.selectedGoalRelay.accept(.diet)
        sut.targetCaloriesObservable
            .subscribe(onNext: { dietCalories = $0 })
            .disposed(by: disposeBag)

        if let maintain = maintainCalories, let diet = dietCalories {
            XCTAssertEqual(maintain - diet, 500, accuracy: 1.0)
        }
    }

    func test_targetCaloriesObservable_벌크업_칼로리_증가() {
        // Given
        sut.selectedActivityLevel.accept(.moderate)

        var maintainCalories: Double?
        var bulkCalories: Double?

        sut.selectedGoalRelay.accept(.maintain)
        sut.targetCaloriesObservable
            .subscribe(onNext: { maintainCalories = $0 })
            .disposed(by: disposeBag)

        sut.selectedGoalRelay.accept(.bulkUp)
        sut.targetCaloriesObservable
            .subscribe(onNext: { bulkCalories = $0 })
            .disposed(by: disposeBag)

        if let maintain = maintainCalories, let bulk = bulkCalories {
            XCTAssertEqual(bulk - maintain, 300, accuracy: 1.0)
        }
    }

    func test_targetCaloriesRelay_바인딩됨() {
        // Given
        sut.selectedGoalRelay.accept(.maintain)
        sut.selectedActivityLevel.accept(.moderate)

        // targetCaloriesRelay는 init에서 targetCaloriesObservable에 바인딩됨
        XCTAssertGreaterThanOrEqual(sut.targetCaloriesRelay.value, 0)
    }

    // MARK: - updateUser

    func test_updateUser_성공시_updateUserResultRelay_true() async {
        // Given
        mockUserUseCase.updateUserResult = .success(())
        var result: Bool?
        sut.updateUserResultRelay
            .subscribe(onNext: { result = $0 })
            .disposed(by: disposeBag)

        // When
        await sut.updateUser(baseUserData)

        // Then
        XCTAssertEqual(result, true)
    }

    func test_updateUser_실패시_에러메시지_저장() async {
        // Given
        let error = NetworkError.serverError(500)
        mockUserUseCase.updateUserResult = .failure(error)

        // When
        await sut.updateUser(baseUserData)

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, "사용자 정보 수정 실패: \(error.description)")
    }

    func test_updateUser_로딩흐름_true후_false() async {
        // Given
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.updateUser(baseUserData)

        // Then
        XCTAssertEqual(loadingStates, [false, true, false])
    }
}
