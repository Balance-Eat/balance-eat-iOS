//
//  ReminderRepositoryProtocol.swift
//  BalanceEat
//
//  Created by 김견 on 12/4/25.
//

import Foundation

protocol ReminderRepositoryProtocol {
    func getReminderList(page: Int, size: Int, userId: String) async -> Result<ReminderListData, NetworkError>
    func createReminder(reminderData: ReminderDataForCreate, userId: String) async -> Result<ReminderDetailData, NetworkError>
    func getReminderDetail(reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError>
    func updateReminder(reminderData: ReminderDataForCreate, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError>
    func deleteReminder(reminderId: Int, userId: String) async -> Result<Void, NetworkError>
    func updateReminderActivation(isActive: Bool, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError>
}
