//
//  NotificationRepositoryProtocol.swift
//  BalanceEat
//
//  Created by 김견 on 11/21/25.
//

import Foundation

protocol NotificationRepositoryProtocol {
    func createNotification(notificationRequestDTO: NotificationRequestDTO, userId: String) async -> Result<NotificationResponseDTO, NetworkError>
    func updateActivation(isActive: Bool, deviceId: Int, userId: String) async -> Result<NotificationResponseDTO, NetworkError>
    func getCurrentDevice(userId: String, agentId: String) async -> Result<NotificationResponseDTO, NetworkError>
}
