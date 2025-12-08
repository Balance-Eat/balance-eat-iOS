//
//  ReminderRepository.swift
//  BalanceEat
//
//  Created by 김견 on 12/4/25.
//

import Foundation

struct ReminderRepository: ReminderRepositoryProtocol {
    private let apiClient = APIClient.shared
    
    func getReminderList(page: Int, size: Int, userId: String) async -> Result<ReminderListResponseDTO, NetworkError> {
        let endPoint = ReminderEndPoints.getReminderList(page: page, size: size, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<ReminderListResponseDTO>.self
        )
        
        switch result {
        case .success(let response):
            print("get reminder list success")
            return .success(response.data)
        case .failure(let error):
            print("get reminder list failed: \(error)")
            return .failure(error)
        }
    }
    func createReminder(reminderRequestDTO: ReminderRequestDTO, userId: String) async -> Result<ReminderDetailDTO, NetworkError> {
        let endPoint = ReminderEndPoints.createReminder(reminderRequestDTO: reminderRequestDTO, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<ReminderDetailDTO>.self
        )
        
        switch result {
        case .success(let response):
            print("create reminder success")
            return .success(response.data)
        case .failure(let error):
            print("create reminder failed: \(error)")
            return .failure(error)
        }
    }
    func getReminderDetail(reminderId: Int, userId: String) async -> Result<ReminderDetailDTO, NetworkError> {
        let endPoint = ReminderEndPoints.getReminderDetail(reminderId: reminderId, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<ReminderDetailDTO>.self
        )
        
        switch result {
        case .success(let response):
            print("get reminder detail success")
            return .success(response.data)
        case .failure(let error):
            print("get reminder detail failed: \(error)")
            return .failure(error)
        }
    }
    func updateReminder(reminderRequestDTO: ReminderRequestDTO, reminderId: Int, userId: String) async -> Result<ReminderDetailDTO, NetworkError> {
        let endPoint = ReminderEndPoints.updateReminder(reminderRequestDTO: reminderRequestDTO, reminderId: reminderId, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<ReminderDetailDTO>.self
        )
        
        switch result {
        case .success(let response):
            print("update reminder success")
            return .success(response.data)
        case .failure(let error):
            print("update reminder failed: \(error)")
            return .failure(error)
        }
    }
    func deleteReminder(reminderId: Int, userId: String) async -> Result<Void, NetworkError> {
        let endPoint = ReminderEndPoints.deleteReminder(reminderId: reminderId, userId: userId)
        return await apiClient.requestVoid(endpoint: endPoint)
    }
    func updateReminderActivation(isActive: Bool, reminderId: Int, userId: String) async -> Result<ReminderDetailDTO, NetworkError> {
        let endPoint = ReminderEndPoints.updateReminderActivation(isActive: isActive, reminderId: reminderId, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<ReminderDetailDTO>.self
        )
        
        switch result {
        case .success(let response):
            print("update reminder activation success")
            return .success(response.data)
        case .failure(let error):
            print("update reminder activation failed: \(error)")
            return .failure(error)
        }
    }
}
