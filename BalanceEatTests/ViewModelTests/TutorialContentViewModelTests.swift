//
//  TutorialContentViewModelTests.swift
//  BalanceEatTests
//

@testable import BalanceEat
import XCTest
import RxSwift

@MainActor
final class TutorialContentViewModelTests: XCTestCase {

    private var sut: TutorialContentViewModel!
    private var mockUserUseCase: MockUserUseCase!
    private var disposeBag: DisposeBag!

    private let sampleRequest = UserCreateRequest(
        uuid: "test-uuid",
        name: "홍길동",
        gender: .male,
        age: 25,
        height: 175.0,
        weight: 70.0,
        goalType: .maintain,
        email: nil,
        activityLevel: .moderate,
        smi: nil,
        fatPercentage: nil,
        targetWeight: 68.0,
        targetCalorie: 2000.0,
        targetSmi: nil,
        targetFatPercentage: nil,
        targetCarbohydrates: nil,
        targetProtein: nil,
        targetFat: nil,
        providerId: nil,
        providerType: nil
    )

    override func setUp() async throws {
        try await super.setUp()
        mockUserUseCase = MockUserUseCase()
        disposeBag = DisposeBag()
        sut = TutorialContentViewModel(userUseCase: mockUserUseCase)
    }

    override func tearDown() async throws {
        sut = nil
        mockUserUseCase = nil
        disposeBag = nil
        try await super.tearDown()
    }

    // MARK: - createUser

    func test_createUser_성공시_onCreateUserSuccessRelay_발행() async {
        // Given
        mockUserUseCase.createUserResult = .success(())
        var successCount = 0
        sut.onCreateUserSuccessRelay
            .subscribe(onNext: { successCount += 1 })
            .disposed(by: disposeBag)

        // When
        await sut.createUser(sampleRequest)

        // Then
        XCTAssertEqual(successCount, 1)
    }

    func test_createUser_성공시_UUID_저장() async {
        // Given
        mockUserUseCase.createUserResult = .success(())
        mockUserUseCase.saveUserUUIDResult = .success(())

        // When
        await sut.createUser(sampleRequest)

        // Then: 에러 없이 완료
        XCTAssertNil(sut.toastMessageRelay.value)
    }

    func test_createUser_실패시_에러메시지_저장() async {
        // Given
        let error = NetworkError.serverError(500)
        mockUserUseCase.createUserResult = .failure(error)

        // When
        await sut.createUser(sampleRequest)

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, "유저 생성에 실패했습니다. \(error.description)")
    }

    func test_createUser_실패시_onCreateUserSuccessRelay_미발행() async {
        // Given
        mockUserUseCase.createUserResult = .failure(.serverError(500))
        var successCount = 0
        sut.onCreateUserSuccessRelay
            .subscribe(onNext: { successCount += 1 })
            .disposed(by: disposeBag)

        // When
        await sut.createUser(sampleRequest)

        // Then
        XCTAssertEqual(successCount, 0)
    }

    func test_createUser_로딩흐름_true후_false() async {
        // Given
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.createUser(sampleRequest)

        // Then
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    func test_createUser_UUID_저장실패시_에러메시지() async {
        // Given
        mockUserUseCase.createUserResult = .success(())
        mockUserUseCase.saveUserUUIDResult = .failure(.saveError("uuid"))

        // When
        await sut.createUser(sampleRequest)

        // Then
        XCTAssertNotNil(sut.toastMessageRelay.value)
    }

    // MARK: - getUserUUID

    func test_getUserUUID_성공시_uuid_반환() {
        // Given
        mockUserUseCase.getUserUUIDResult = .success("my-uuid")

        // When
        let result = sut.getUserUUID()

        // Then
        XCTAssertEqual(result, "my-uuid")
    }

    func test_getUserUUID_실패시_nil_반환() {
        // Given
        mockUserUseCase.getUserUUIDResult = .failure(.readError("uuid"))

        // When
        let result = sut.getUserUUID()

        // Then
        XCTAssertNil(result)
    }

    func test_getUserUUID_실패시_에러메시지_저장() {
        // Given
        mockUserUseCase.getUserUUIDResult = .failure(.readError("uuid"))

        // When
        _ = sut.getUserUUID()

        // Then
        XCTAssertNotNil(sut.toastMessageRelay.value)
    }
}
