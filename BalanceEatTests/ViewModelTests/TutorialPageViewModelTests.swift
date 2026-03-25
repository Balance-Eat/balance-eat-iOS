//
//  TutorialPageViewModelTests.swift
//  BalanceEatTests
//

@testable import BalanceEat
import XCTest
import RxSwift

final class TutorialPageViewModelTests: XCTestCase {

    private var sut: TutorialPageViewModel!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        sut = TutorialPageViewModel()
    }

    override func tearDown() {
        sut = nil
        disposeBag = nil
        super.tearDown()
    }

    // MARK: - BMR 계산

    func test_BMR_남성_공식_적용() {
        // Given: weight=70, height=175, age=25, gender=male
        // BMR = 10*70 + 6.25*175 - 5*25 + 5 = 1673.75 → 1673
        var data = TutorialData()
        data.gender = .male
        data.age = 25
        data.height = 175.0
        data.weight = 70.0
        data.activityLevel = .moderate

        sut.dataRelay.accept(data)

        // targetCaloriesObservable을 통해 간접 검증
        sut.goalTypeRelay.accept(.maintain)
        var calories: Double?
        sut.targetCaloriesObservable
            .subscribe(onNext: { calories = $0 })
            .disposed(by: disposeBag)

        // maintain + moderate: 1673 * 1.55 = 2593.15
        XCTAssertEqual(calories ?? 0, 1673.0 * 1.55, accuracy: 1.0)
    }

    func test_BMR_여성_공식_적용() {
        // Given: weight=55, height=163, age=28, gender=female
        // BMR = 10*55 + 6.25*163 - 5*28 - 161 = 1267.75 → 1267
        var data = TutorialData()
        data.gender = .female
        data.age = 28
        data.height = 163.0
        data.weight = 55.0
        data.activityLevel = .moderate

        sut.dataRelay.accept(data)
        sut.goalTypeRelay.accept(.maintain)

        var calories: Double?
        sut.targetCaloriesObservable
            .subscribe(onNext: { calories = $0 })
            .disposed(by: disposeBag)

        // 1267 * 1.55 = 1963.85
        XCTAssertEqual(calories ?? 0, 1267.0 * 1.55, accuracy: 1.0)
    }

    // MARK: - targetCaloriesObservable

    func test_targetCaloriesObservable_activityLevel_none이면_0() {
        // Given
        var data = TutorialData()
        data.gender = .male
        data.age = 25
        data.height = 175.0
        data.weight = 70.0
        data.activityLevel = nil

        sut.dataRelay.accept(data)
        sut.goalTypeRelay.accept(.maintain)

        var calories: Double?
        sut.targetCaloriesObservable
            .subscribe(onNext: { calories = $0 })
            .disposed(by: disposeBag)

        XCTAssertEqual(calories, 0)
    }

    func test_targetCaloriesObservable_다이어트_500_차감() {
        // Given
        var data = TutorialData()
        data.gender = .male
        data.age = 25
        data.height = 175.0
        data.weight = 70.0
        data.activityLevel = .moderate

        sut.dataRelay.accept(data)

        var maintainCalories: Double?
        var dietCalories: Double?

        sut.goalTypeRelay.accept(.maintain)
        sut.targetCaloriesObservable
            .subscribe(onNext: { maintainCalories = $0 })
            .disposed(by: disposeBag)

        sut.goalTypeRelay.accept(.diet)
        sut.targetCaloriesObservable
            .subscribe(onNext: { dietCalories = $0 })
            .disposed(by: disposeBag)

        if let maintain = maintainCalories, let diet = dietCalories {
            XCTAssertEqual(maintain - diet, 500, accuracy: 1.0)
        }
    }

    func test_targetCaloriesObservable_벌크업_300_추가() {
        // Given
        var data = TutorialData()
        data.gender = .male
        data.age = 25
        data.height = 175.0
        data.weight = 70.0
        data.activityLevel = .moderate

        sut.dataRelay.accept(data)

        var maintainCalories: Double?
        var bulkCalories: Double?

        sut.goalTypeRelay.accept(.maintain)
        sut.targetCaloriesObservable
            .subscribe(onNext: { maintainCalories = $0 })
            .disposed(by: disposeBag)

        sut.goalTypeRelay.accept(.bulkUp)
        sut.targetCaloriesObservable
            .subscribe(onNext: { bulkCalories = $0 })
            .disposed(by: disposeBag)

        if let maintain = maintainCalories, let bulk = bulkCalories {
            XCTAssertEqual(bulk - maintain, 300, accuracy: 1.0)
        }
    }

    func test_targetCaloriesRelay_바인딩됨() {
        // Given
        var data = TutorialData()
        data.gender = .male
        data.age = 25
        data.height = 175.0
        data.weight = 70.0
        data.activityLevel = .moderate

        // When
        sut.dataRelay.accept(data)
        sut.goalTypeRelay.accept(.maintain)

        // Then: targetCaloriesRelay는 init에서 바인딩됨
        XCTAssertGreaterThan(sut.targetCaloriesRelay.value, 0)
    }

    // MARK: - generateRandomNickname

    func test_generateRandomNickname_비어있지_않음() {
        let nickname = sut.generateRandomNickname()
        XCTAssertFalse(nickname.isEmpty)
    }

    func test_generateRandomNickname_호출마다_생성됨() {
        let n1 = sut.generateRandomNickname()
        let n2 = sut.generateRandomNickname()
        // 랜덤이므로 같을 수도 있지만 둘 다 비어 있지 않아야 함
        XCTAssertFalse(n1.isEmpty)
        XCTAssertFalse(n2.isEmpty)
    }
}
