//
//  SetRemindNotiViewModelTests.swift
//  BalanceEatTests
//

@testable import BalanceEat
import XCTest
import RxSwift

@MainActor
final class SetRemindNotiViewModelTests: XCTestCase {

    private var sut: SetRemindNotiViewModel!
    private var mockNotificationUseCase: MockNotificationUseCase!
    private var mockReminderUseCase: MockReminderUseCase!
    private var mockUserUseCase: MockUserUseCase!
    private var disposeBag: DisposeBag!

    override func setUp() async throws {
        try await super.setUp()
        mockNotificationUseCase = MockNotificationUseCase()
        mockReminderUseCase = MockReminderUseCase()
        mockUserUseCase = MockUserUseCase()
        disposeBag = DisposeBag()
        sut = SetRemindNotiViewModel(
            notificationUseCase: mockNotificationUseCase,
            reminderUseCase: mockReminderUseCase,
            userUseCase: mockUserUseCase
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockNotificationUseCase = nil
        mockReminderUseCase = nil
        mockUserUseCase = nil
        disposeBag = nil
        try await super.tearDown()
    }

    // MARK: - getReminderList

    func test_getReminderList_성공시_reminderListRelay_업데이트() async {
        // Given
        let reminders = [ReminderData.fixture(id: 1), ReminderData.fixture(id: 2)]
        mockReminderUseCase.getReminderListResult = .success(.fixture(items: reminders))

        // When
        await sut.getReminderList()

        // Then
        XCTAssertEqual(sut.reminderListRelay.value.count, 2)
    }

    func test_getReminderList_성공시_currentPage_증가() async {
        // Given
        mockReminderUseCase.getReminderListResult = .success(.fixture(totalPages: 3))

        // When
        await sut.getReminderList()

        // Then
        XCTAssertEqual(sut.currentPage, 1)
    }

    func test_getReminderList_성공시_totalPage_업데이트() async {
        // Given
        mockReminderUseCase.getReminderListResult = .success(.fixture(totalPages: 5))

        // When
        await sut.getReminderList()

        // Then
        XCTAssertEqual(sut.totalPage, 5)
    }

    func test_getReminderList_실패시_에러메시지_저장() async {
        // Given
        mockReminderUseCase.getReminderListResult = .failure(.serverError(500))

        // When
        await sut.getReminderList()

        // Then
        XCTAssertNotNil(sut.toastMessageRelay.value)
    }

    func test_getReminderList_로딩흐름_true후_false() async {
        // Given
        var loadingStates: [Bool] = []
        sut.loadingRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.getReminderList()

        // Then
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    // MARK: - fetchReminderList: 페이지네이션

    func test_fetchReminderList_isLastPage시_UseCase_미호출() async {
        // 초기 상태: currentPage=0, totalPage=0 → isLastPage=true
        let callCountBefore = mockReminderUseCase.getReminderListCallCount

        // When
        await sut.fetchReminderList()

        // Then: 추가 호출 없음
        XCTAssertEqual(mockReminderUseCase.getReminderListCallCount, callCountBefore)
    }

    func test_fetchReminderList_성공시_목록_누적() async {
        // Given: 첫 페이지 로드
        let firstItems = [ReminderData.fixture(id: 1)]
        mockReminderUseCase.getReminderListResult = .success(.fixture(items: firstItems, totalPages: 3))
        await sut.getReminderList()

        // When: 다음 페이지 로드
        let secondItems = [ReminderData.fixture(id: 2)]
        mockReminderUseCase.getReminderListResult = .success(.fixture(items: secondItems, totalPages: 3))
        await sut.fetchReminderList()

        // Then: 기존 + 새 항목
        XCTAssertEqual(sut.reminderListRelay.value.count, 2)
    }

    func test_fetchReminderList_currentPage_증가() async {
        // Given: 다음 페이지가 있는 상태
        mockReminderUseCase.getReminderListResult = .success(.fixture(totalPages: 5))
        await sut.getReminderList()
        XCTAssertEqual(sut.currentPage, 1)

        // When
        await sut.fetchReminderList()

        // Then
        XCTAssertEqual(sut.currentPage, 2)
    }

    func test_fetchReminderList_실패시_에러메시지_저장() async {
        // Given: 다음 페이지가 있는 상태
        mockReminderUseCase.getReminderListResult = .success(.fixture(totalPages: 3))
        await sut.getReminderList()

        // When
        mockReminderUseCase.getReminderListResult = .failure(.serverError(500))
        await sut.fetchReminderList()

        // Then
        XCTAssertNotNil(sut.toastMessageRelay.value)
    }

    // MARK: - deleteReminder

    func test_deleteReminder_성공시_목록에서_제거() async {
        // Given
        let reminder = ReminderData.fixture(id: 42)
        sut.reminderListRelay.accept([reminder])
        mockReminderUseCase.deleteReminderResult = .success(())

        // When
        await sut.deleteReminder(reminderId: 42)

        // Then
        XCTAssertTrue(sut.reminderListRelay.value.isEmpty)
    }

    func test_deleteReminder_성공시_올바른_id_전달() async {
        // Given
        sut.reminderListRelay.accept([ReminderData.fixture(id: 99)])

        // When
        await sut.deleteReminder(reminderId: 99)

        // Then
        XCTAssertEqual(mockReminderUseCase.capturedDeleteReminderId, 99)
    }

    func test_deleteReminder_실패시_목록_미변경() async {
        // Given
        let reminder = ReminderData.fixture(id: 1)
        sut.reminderListRelay.accept([reminder])
        mockReminderUseCase.deleteReminderResult = .failure(.serverError(500))

        // When
        await sut.deleteReminder(reminderId: 1)

        // Then
        XCTAssertEqual(sut.reminderListRelay.value.count, 1)
    }

    // MARK: - createReminder

    func test_createReminder_성공시_successRelay_발행() async {
        // Given
        let reminderData = ReminderDataForCreate(
            content: "운동하기",
            sendTime: "08:00",
            isActive: true,
            dayOfWeeks: ["MONDAY"]
        )
        mockReminderUseCase.createReminderResult = .success(.fixture())

        var receivedSuccess = false
        sut.successToSaveReminderRelay
            .subscribe(onNext: { receivedSuccess = true })
            .disposed(by: disposeBag)

        // When
        await sut.createReminder(reminderDataForCreate: reminderData)

        // Then
        XCTAssertTrue(receivedSuccess)
    }

    func test_createReminder_실패시_에러메시지_저장() async {
        // Given
        let reminderData = ReminderDataForCreate(
            content: "운동하기",
            sendTime: "08:00",
            isActive: true,
            dayOfWeeks: ["MONDAY"]
        )
        mockReminderUseCase.createReminderResult = .failure(.serverError(500))

        // When
        await sut.createReminder(reminderDataForCreate: reminderData)

        // Then
        XCTAssertNotNil(sut.toastMessageRelay.value)
    }
}
