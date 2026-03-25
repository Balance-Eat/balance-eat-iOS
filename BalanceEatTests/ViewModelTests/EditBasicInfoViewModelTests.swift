//
//  EditBasicInfoViewModelTests.swift
//  BalanceEatTests
//

@testable import BalanceEat
import XCTest
import RxSwift

@MainActor
final class EditBasicInfoViewModelTests: XCTestCase {

    private var sut: EditBasicInfoViewModel!
    private var mockUserUseCase: MockUserUseCase!
    private var disposeBag: DisposeBag!

    private let baseUserData = UserData.fixture(
        name: "홍길동",
        gender: .male,
        age: 25,
        height: 175.0
    )

    override func setUp() async throws {
        try await super.setUp()
        mockUserUseCase = MockUserUseCase()
        disposeBag = DisposeBag()
        sut = EditBasicInfoViewModel(userData: baseUserData, userUseCase: mockUserUseCase)
    }

    override func tearDown() async throws {
        sut = nil
        mockUserUseCase = nil
        disposeBag = nil
        try await super.tearDown()
    }

    // MARK: - 초기화

    func test_init_relay_초기값_userData로_설정() {
        XCTAssertEqual(sut.nameRelay.value, "홍길동")
        XCTAssertEqual(sut.genderRelay.value, .male)
        XCTAssertEqual(sut.ageRelay.value, 25)
        XCTAssertEqual(sut.heightRelay.value, 175.0)
    }

    func test_init_userRelay_userData로_설정() {
        XCTAssertEqual(sut.userRelay.value?.name, "홍길동")
    }

    // MARK: - isUnchangedObservable

    func test_isUnchangedObservable_변경없으면_true() {
        var result: Bool?
        sut.isUnchangedObservable
            .subscribe(onNext: { result = $0 })
            .disposed(by: disposeBag)

        XCTAssertEqual(result, true)
    }

    func test_isUnchangedObservable_이름변경시_false() {
        var result: Bool?
        sut.isUnchangedObservable
            .subscribe(onNext: { result = $0 })
            .disposed(by: disposeBag)

        sut.nameRelay.accept("김철수")

        XCTAssertEqual(result, false)
    }

    func test_isUnchangedObservable_나이변경시_false() {
        var result: Bool?
        sut.isUnchangedObservable
            .subscribe(onNext: { result = $0 })
            .disposed(by: disposeBag)

        sut.ageRelay.accept(30)

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
        sut.nameRelay.accept("김철수")
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
}
