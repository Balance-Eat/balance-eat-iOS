//
//  EditTargetViewModelTests.swift
//  BalanceEatTests
//

@testable import BalanceEat
import XCTest
import RxSwift

@MainActor
final class EditTargetViewModelTests: XCTestCase {

    private var sut: EditTargetViewModel!
    private var mockUserUseCase: MockUserUseCase!
    private var disposeBag: DisposeBag!

    private let baseUserData = UserData.fixture(
        weight: 70.0,
        targetWeight: 68.0,
        smi: nil,
        fatPercentage: nil
    )

    override func setUp() async throws {
        try await super.setUp()
        mockUserUseCase = MockUserUseCase()
        disposeBag = DisposeBag()
        sut = EditTargetViewModel(userData: baseUserData, userUseCase: mockUserUseCase)
    }

    override func tearDown() async throws {
        sut = nil
        mockUserUseCase = nil
        disposeBag = nil
        try await super.tearDown()
    }

    // MARK: - 초기화

    func test_init_relay_초기값_userData로_설정() {
        XCTAssertEqual(sut.currentWeightRelay.value, 70.0)
        XCTAssertEqual(sut.targetWeightRelay.value, 68.0)
        XCTAssertNil(sut.currentSMIRelay.value)
        XCTAssertNil(sut.targetSMIRelay.value)
    }

    // MARK: - isUnchangedObservable

    func test_isUnchangedObservable_변경없으면_true() {
        var result: Bool?
        sut.isUnchangedObservable
            .subscribe(onNext: { result = $0 })
            .disposed(by: disposeBag)

        XCTAssertEqual(result, true)
    }

    func test_isUnchangedObservable_현재체중변경시_false() {
        var result: Bool?
        sut.isUnchangedObservable
            .subscribe(onNext: { result = $0 })
            .disposed(by: disposeBag)

        sut.currentWeightRelay.accept(75.0)

        XCTAssertEqual(result, false)
    }

    func test_isUnchangedObservable_목표체중변경시_false() {
        var result: Bool?
        sut.isUnchangedObservable
            .subscribe(onNext: { result = $0 })
            .disposed(by: disposeBag)

        sut.targetWeightRelay.accept(65.0)

        XCTAssertEqual(result, false)
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
        await sut.updateUser()

        // Then
        XCTAssertEqual(result, true)
    }

    func test_updateUser_실패시_updateUserResultRelay_false() async {
        // Given
        mockUserUseCase.updateUserResult = .failure(.serverError(500))
        var result: Bool?
        sut.updateUserResultRelay
            .subscribe(onNext: { result = $0 })
            .disposed(by: disposeBag)

        // When
        await sut.updateUser()

        // Then
        XCTAssertEqual(result, false)
    }

    func test_updateUser_실패시_에러메시지_저장() async {
        // Given
        let error = NetworkError.serverError(500)
        mockUserUseCase.updateUserResult = .failure(error)

        // When
        await sut.updateUser()

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
        await sut.updateUser()

        // Then
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    func test_updateUser_변경된_relay값이_UseCase에_전달됨() async {
        // Given
        mockUserUseCase.updateUserResult = .success(())
        sut.currentWeightRelay.accept(75.0)
        sut.targetWeightRelay.accept(72.0)

        // When
        await sut.updateUser()

        // Then: 에러 없이 성공
        XCTAssertNil(sut.toastMessageRelay.value)
    }
}
