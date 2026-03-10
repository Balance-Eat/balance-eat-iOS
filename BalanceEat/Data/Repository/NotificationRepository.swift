//
//  NotificationRepository.swift
//  BalanceEat
//
//  Created by 김견 on 11/21/25.
//

import Foundation

struct NotificationRepository: NotificationRepositoryProtocol {
    private let apiClient = APIClient.shared

    func createNotification(notificationRequestDTO: NotificationRequestDTO, userId: String) async -> Result<NotificationResponseDTO, NetworkError> {
        let endPoint = NotificationEndpoints.create(notificationRequestDTO: notificationRequestDTO, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<NotificationResponseDTO>.self
        )

        switch result {
        case .success(let response):
            return .success(response.data)
        case .failure(let error):
            return .failure(error)
        }
    }

    func updateActivation(isActive: Bool, deviceId: Int, userId: String) async -> Result<NotificationResponseDTO, NetworkError> {
        let endPoint = NotificationEndpoints.updateActivation(isActive: isActive, deviceId: deviceId, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<NotificationResponseDTO>.self
        )

        switch result {
        case .success(let response):
            return .success(response.data)
        case .failure(let error):
            return .failure(error)
        }
    }

    func getCurrentDevice(userId: String, agentId: String) async -> Result<NotificationResponseDTO, NetworkError> {
        let endPoint = NotificationEndpoints.getCurrentDevice(userId: userId, agentId: agentId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<NotificationResponseDTO>.self
        )

        switch result {
        case .success(let response):
            return .success(response.data)
        case .failure(let error):
            return .failure(error)
        }
    }
}
