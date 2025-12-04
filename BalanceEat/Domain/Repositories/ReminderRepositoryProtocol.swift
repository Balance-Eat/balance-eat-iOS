//
//  ReminderRepositoryProtocol.swift
//  BalanceEat
//
//  Created by 김견 on 12/4/25.
//

import Foundation

protocol ReminderRepositoryProtocol {
    func getReminderList(userId: String) async -> Result<ReminderListResponseDTO, NetworkError>
    func createReminder(reminderRequestDTO: ReminderRequestDTO, userId: String) async -> Result<ReminderDetailDTO, NetworkError>
    func getReminderDetail(reminderId: Int, userId: String) async -> Result<ReminderDetailDTO, NetworkError>
    func updateReminder(reminderRequestDTO: ReminderRequestDTO, reminderId: Int, userId: String) async -> Result<ReminderDetailDTO, NetworkError>
    func deleteReminder(reminderId: Int, userId: String) async -> Result<Void, NetworkError>
    func updateReminderActivation(isActive: Bool, reminderId: Int, userId: String) async -> Result<ReminderDetailDTO, NetworkError>
}
