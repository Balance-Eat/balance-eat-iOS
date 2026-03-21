//
//  ReminderRepository.swift
//  BalanceEat
//
//  Created by 김견 on 12/4/25.
//

import Foundation

struct DefaultReminderRepository: ReminderRepository {
    private let apiClient = APIClient.shared

    func getReminderList(page: Int, size: Int, userId: String) async -> Result<ReminderListData, NetworkError> {
        let endPoint = ReminderEndPoints.getReminderList(page: page, size: size, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<ReminderListResponseDTO>.self
        )

        switch result {
        case .success(let response): return .success(response.data.DTOToModel())
        case .failure(let error): return .failure(error)
        }
    }

    func createReminder(reminderData: ReminderDataForCreate, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        let dto = ReminderRequestDTO(
            content: reminderData.content,
            sendTime: reminderData.sendTime,
            isActive: reminderData.isActive,
            dayOfWeeks: reminderData.dayOfWeeks
        )
        let endPoint = ReminderEndPoints.createReminder(reminderRequestDTO: dto, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<ReminderDetailDTO>.self
        )

        switch result {
        case .success(let response): return .success(response.data.DTOToModel())
        case .failure(let error): return .failure(error)
        }
    }

    func getReminderDetail(reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        let endPoint = ReminderEndPoints.getReminderDetail(reminderId: reminderId, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<ReminderDetailDTO>.self
        )

        switch result {
        case .success(let response): return .success(response.data.DTOToModel())
        case .failure(let error): return .failure(error)
        }
    }

    func updateReminder(reminderData: ReminderDataForCreate, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        let dto = ReminderRequestDTO(
            content: reminderData.content,
            sendTime: reminderData.sendTime,
            isActive: reminderData.isActive,
            dayOfWeeks: reminderData.dayOfWeeks
        )
        let endPoint = ReminderEndPoints.updateReminder(reminderRequestDTO: dto, reminderId: reminderId, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<ReminderDetailDTO>.self
        )

        switch result {
        case .success(let response): return .success(response.data.DTOToModel())
        case .failure(let error): return .failure(error)
        }
    }

    func deleteReminder(reminderId: Int, userId: String) async -> Result<Void, NetworkError> {
        let endPoint = ReminderEndPoints.deleteReminder(reminderId: reminderId, userId: userId)
        return await apiClient.requestVoid(endpoint: endPoint)
    }

    func updateReminderActivation(isActive: Bool, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        let endPoint = ReminderEndPoints.updateReminderActivation(isActive: isActive, reminderId: reminderId, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<ReminderDetailDTO>.self
        )

        switch result {
        case .success(let response): return .success(response.data.DTOToModel())
        case .failure(let error): return .failure(error)
        }
    }
}
