//
//  NotificationRepository.swift
//  BalanceEat
//
//  Created by 김견 on 11/21/25.
//

import Foundation

struct DefaultNotificationRepository: NotificationRepository {
    private let apiClient: any APIClientProtocol

    init(apiClient: any APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    func createNotification(request: NotificationCreateRequest, userId: String) async -> Result<NotificationData, NetworkError> {
        let dto = NotificationRequestDTO(
            agentId: request.agentId,
            osType: request.osType,
            deviceName: request.deviceName,
            isActive: request.isActive
        )
        let endPoint = NotificationEndpoints.create(notificationRequestDTO: dto, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<NotificationResponseDTO>.self
        )

        switch result {
        case .success(let response): return .success(response.data.DTOToModel())
        case .failure(let error): return .failure(error)
        }
    }

    func updateActivation(isActive: Bool, deviceId: Int, userId: String) async -> Result<NotificationData, NetworkError> {
        let endPoint = NotificationEndpoints.updateActivation(isActive: isActive, deviceId: deviceId, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<NotificationResponseDTO>.self
        )

        switch result {
        case .success(let response): return .success(response.data.DTOToModel())
        case .failure(let error): return .failure(error)
        }
    }

    func getCurrentDevice(userId: String, agentId: String) async -> Result<NotificationData, NetworkError> {
        let endPoint = NotificationEndpoints.getCurrentDevice(userId: userId, agentId: agentId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<NotificationResponseDTO>.self
        )

        switch result {
        case .success(let response): return .success(response.data.DTOToModel())
        case .failure(let error): return .failure(error)
        }
    }
}
