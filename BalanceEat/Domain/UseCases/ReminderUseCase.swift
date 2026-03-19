//
//  ReminderUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 12/4/25.
//

import Foundation

protocol ReminderUseCaseProtocol {
    func getReminderList(page: Int, size: Int, userId: String) async -> Result<ReminderListData, NetworkError>
    func createReminder(reminderDataForCreate: ReminderDataForCreate, userId: String) async -> Result<ReminderDetailData, NetworkError>
    func getReminderDetail(reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError>
    func updateReminder(reminderDataForCreate: ReminderDataForCreate, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError>
    func deleteReminder(reminderId: Int, userId: String) async -> Result<Void, NetworkError>
    func updateReminderActivation(isActive: Bool, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError>
}

struct ReminderUseCase: ReminderUseCaseProtocol {
    private let repository: ReminderRepositoryProtocol

    init(repository: ReminderRepositoryProtocol) {
        self.repository = repository
    }

    func getReminderList(page: Int, size: Int, userId: String) async -> Result<ReminderListData, NetworkError> {
        await repository.getReminderList(page: page, size: size, userId: userId)
    }

    func createReminder(reminderDataForCreate: ReminderDataForCreate, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        await repository.createReminder(reminderData: reminderDataForCreate, userId: userId)
    }

    func getReminderDetail(reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        await repository.getReminderDetail(reminderId: reminderId, userId: userId)
    }

    func updateReminder(reminderDataForCreate: ReminderDataForCreate, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        await repository.updateReminder(reminderData: reminderDataForCreate, reminderId: reminderId, userId: userId)
    }

    func deleteReminder(reminderId: Int, userId: String) async -> Result<Void, NetworkError> {
        await repository.deleteReminder(reminderId: reminderId, userId: userId)
    }

    func updateReminderActivation(isActive: Bool, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        await repository.updateReminderActivation(isActive: isActive, reminderId: reminderId, userId: userId)
    }
}
