//
//  NotificationRepositoryProtocol.swift
//  BalanceEat
//
//  Created by 김견 on 11/21/25.
//

import Foundation

protocol NotificationRepositoryProtocol {
    func createNotification(request: NotificationCreateRequest, userId: String) async -> Result<NotificationData, NetworkError>
    func updateActivation(isActive: Bool, deviceId: Int, userId: String) async -> Result<NotificationData, NetworkError>
    func getCurrentDevice(userId: String, agentId: String) async -> Result<NotificationData, NetworkError>
}
