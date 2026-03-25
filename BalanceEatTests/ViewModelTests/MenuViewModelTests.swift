//
//  MenuViewModelTests.swift
//  BalanceEatTests
//

@testable import BalanceEat
import XCTest
import RxSwift

@MainActor
final class MenuViewModelTests: XCTestCase {

    private var sut: MenuViewModel!
    private var mockUserUseCase: MockUserUseCase!
    private var mockNotificationUseCase: MockNotificationUseCase!
    private var disposeBag: DisposeBag!

    override func setUp() async throws {
        try await super.setUp()
        mockUserUseCase = MockUserUseCase()
        mockNotificationUseCase = MockNotificationUseCase()
        disposeBag = DisposeBag()
        sut = MenuViewModel(userUseCase: mockUserUseCase, notificationUseCase: mockNotificationUseCase)
    }

    override func tearDown() async throws {
        sut = nil
        mockUserUseCase = nil
        mockNotificationUseCase = nil
        disposeBag = nil
        try await super.tearDown()
    }

    // MARK: - getUser

    func test_getUser_성공시_userRelay_업데이트() async {
        // Given
        let expectedUser = UserData.fixture(name: "홍길동")
        mockUserUseCase.getUserResult = .success(expectedUser)

        // When
        await sut.getUser()

        // Then
        XCTAssertEqual(sut.userRelay.value?.name, "홍길동")
    }

    func test_getUser_실패시_userRelay_미변경() async {
        // Given
        mockUserUseCase.getUserResult = .failure(.serverError(500))

        // When
        await sut.getUser()

        // Then
        XCTAssertNil(sut.userRelay.value)
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

    func test_getUser_UUID_실패시_UseCase_미호출() async {
        // Given
        mockUserUseCase.getUserUUIDResult = .failure(.fetchFailed)

        // When
        await sut.getUser()

        // Then
        XCTAssertNil(sut.userRelay.value)
    }

    func test_getUser_로딩흐름_true후_false() async {
        // Given
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.getUser()

        // Then
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    // MARK: - getNotificationCurrentDevice

    func test_getNotificationCurrentDevice_성공시_notificationRelay_업데이트() async {
        // Given
        let notification = NotificationData.fixture(isActive: true)
        mockNotificationUseCase.getCurrentDeviceResult = .success(notification)

        // When
        await sut.getNotificationCurrentDevice(userId: "1", agentId: "agent-id")

        // Then
        XCTAssertNotNil(sut.notificationRelay.value)
        XCTAssertEqual(sut.notificationRelay.value?.isActive, true)
    }

    func test_getNotificationCurrentDevice_실패시_에러메시지_저장() async {
        // Given
        let error = NetworkError.serverError(404)
        mockNotificationUseCase.getCurrentDeviceResult = .failure(error)

        // When
        await sut.getNotificationCurrentDevice(userId: "1", agentId: "agent-id")

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, "알림 정보 불러오기 실패: \(error.description)")
    }

    // MARK: - updateNotificationActivation

    func test_updateNotificationActivation_실패시_에러메시지_저장() async {
        // Given
        let error = NetworkError.serverError(500)
        mockNotificationUseCase.updateActivationResult = .failure(error)

        // When
        await sut.updateNotificationActivation(isActive: true, deviceId: 1, userId: "1")

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, "알림 정보 업데이트 실패: \(error.description)")
    }

    func test_updateNotificationActivation_성공시_에러메시지_없음() async {
        // Given
        mockNotificationUseCase.updateActivationResult = .success(.fixture())

        // When
        await sut.updateNotificationActivation(isActive: false, deviceId: 1, userId: "1")

        // Then
        XCTAssertNil(sut.toastMessageRelay.value)
    }
}
