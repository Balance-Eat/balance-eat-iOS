//
//  NotificationUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 11/21/25.
//

import Foundation

protocol NotificationUseCaseProtocol {
    func createNotification(request: NotificationCreateRequest, userId: String) async -> Result<NotificationData, NetworkError>
    func updateActivation(isActive: Bool, deviceId: Int, userId: String) async -> Result<NotificationData, NetworkError>
    func getCurrentDevice(userId: String, agentId: String) async -> Result<NotificationData, NetworkError>
}

struct NotificationUseCase: NotificationUseCaseProtocol {
    private let repository: NotificationRepository

    init(repository: NotificationRepository) {
        self.repository = repository
    }

    func createNotification(request: NotificationCreateRequest, userId: String) async -> Result<NotificationData, NetworkError> {
        await repository.createNotification(request: request, userId: userId)
    }

    func updateActivation(isActive: Bool, deviceId: Int, userId: String) async -> Result<NotificationData, NetworkError> {
        await repository.updateActivation(isActive: isActive, deviceId: deviceId, userId: userId)
    }

    func getCurrentDevice(userId: String, agentId: String) async -> Result<NotificationData, NetworkError> {
        await repository.getCurrentDevice(userId: userId, agentId: agentId)
    }
}
