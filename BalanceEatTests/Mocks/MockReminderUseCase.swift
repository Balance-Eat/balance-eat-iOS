//
//  MockReminderUseCase.swift
//  BalanceEatTests
//

@testable import BalanceEat
import Foundation

final class MockReminderUseCase: ReminderUseCaseProtocol {

    var getReminderListResult: Result<ReminderListData, NetworkError> = .success(.fixture())
    var createReminderResult: Result<ReminderDetailData, NetworkError> = .success(.fixture())
    var getReminderDetailResult: Result<ReminderDetailData, NetworkError> = .success(.fixture())
    var updateReminderResult: Result<ReminderDetailData, NetworkError> = .success(.fixture())
    var deleteReminderResult: Result<Void, NetworkError> = .success(())
    var updateReminderActivationResult: Result<ReminderDetailData, NetworkError> = .success(.fixture())

    private(set) var getReminderListCallCount = 0
    private(set) var deleteReminderCallCount = 0
    private(set) var capturedDeleteReminderId: Int?

    func getReminderList(page: Int, size: Int, userId: String) async -> Result<ReminderListData, NetworkError> {
        getReminderListCallCount += 1
        return getReminderListResult
    }

    func createReminder(reminderDataForCreate: ReminderDataForCreate, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        createReminderResult
    }

    func getReminderDetail(reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        getReminderDetailResult
    }

    func updateReminder(reminderDataForCreate: ReminderDataForCreate, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        updateReminderResult
    }

    func deleteReminder(reminderId: Int, userId: String) async -> Result<Void, NetworkError> {
        deleteReminderCallCount += 1
        capturedDeleteReminderId = reminderId
        return deleteReminderResult
    }

    func updateReminderActivation(isActive: Bool, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        updateReminderActivationResult
    }
}
