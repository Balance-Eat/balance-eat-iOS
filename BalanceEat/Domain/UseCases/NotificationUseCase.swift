//
//  NotificationUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 11/21/25.
//

import Foundation

protocol NotificationUseCaseProtocol {
    func createNotification(notificationRequestDTO: NotificationRequestDTO, userId: String) async -> Result<NotificationResponseDTO, NetworkError>
    func updateActivation(isActive: Bool, deviceId: Int, userId: String) async -> Result<NotificationResponseDTO, NetworkError>
    func getCurrentDevice(userId: String, agentId: String) async -> Result<NotificationResponseDTO, NetworkError>
}

struct NotificationUseCase: NotificationUseCaseProtocol {
    private let repository: NotificationRepositoryProtocol
    
    init(repository: NotificationRepositoryProtocol) {
        self.repository = repository
    }
    
    func createNotification(notificationRequestDTO: NotificationRequestDTO, userId: String) async -> Result<NotificationResponseDTO, NetworkError> {
        let response = await repository.createNotification(notificationRequestDTO: notificationRequestDTO, userId: userId)
        
        switch response {
        case .success(let notificationResponseDTO):
            return .success(notificationResponseDTO)
        case .failure(let error):
            return .failure(error)
        }
        
    }
    
    func updateActivation(isActive: Bool, deviceId: Int, userId: String) async -> Result<NotificationResponseDTO, NetworkError> {
        let response = await repository.updateActivation(isActive: isActive, deviceId: deviceId, userId: userId)
        
        switch response {
        case .success(let notificationResponseDTO):
            return .success(notificationResponseDTO)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getCurrentDevice(userId: String, agentId: String) async -> Result<NotificationResponseDTO, NetworkError> {
        let response = await repository.getCurrentDevice(userId: userId, agentId: agentId)
        
        switch response {
        case .success(let notificationResponseDTO):
            return .success(notificationResponseDTO)
        case .failure(let error):
            return .failure(error)
        }
    }
}
