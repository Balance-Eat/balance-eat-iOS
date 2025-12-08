//
//  ReminderUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 12/4/25.
//

import Foundation

protocol ReminderUseCaseProtocol {
    func getReminderList(page: Int, size: Int, userId: String) async -> Result<ReminderListData, NetworkError>
    func createReminder(reminderDataForCreate: ReminderDataForCreate, userId: String) async -> Result<ReminderDetailData, NetworkError>
    func getReminderDetail(reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError>
    func updateReminder(reminderDataForCreate: ReminderDataForCreate, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError>
    func deleteReminder(reminderId: Int, userId: String) async -> Result<Void, NetworkError>
    func updateReminderActivation(isActive: Bool, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError>
}

struct ReminderUseCase: ReminderUseCaseProtocol {
    private let repository: ReminderRepositoryProtocol
    
    init(repository: ReminderRepositoryProtocol) {
        self.repository = repository
    }
    
    func getReminderList(page: Int, size: Int, userId: String) async -> Result<ReminderListData, NetworkError> {
        let response = await repository.getReminderList(page: page, size: size, userId: userId)
        
        switch response {
        case .success(let reminderListResponseDTO):
            return .success(reminderListResponseDTO.DTOToModel())
        case .failure(let error):
            return .failure(error)
        }
    }
    func createReminder(reminderDataForCreate: ReminderDataForCreate, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        let response = await repository.createReminder(reminderRequestDTO: reminderDataForCreate.modelToDTO(), userId: userId)
        
        switch response {
        case .success(let reminderDetailDTO):
            return .success(reminderDetailDTO.DTOToModel())
        case .failure(let error):
            return .failure(error)
        }
    }
    func getReminderDetail(reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        let response = await repository.getReminderDetail(reminderId: reminderId, userId: userId)
        
        switch response {
        case .success(let reminderDetailDTO):
            return .success(reminderDetailDTO.DTOToModel())
        case .failure(let error):
            return .failure(error)
        }
    }
    func updateReminder(reminderDataForCreate: ReminderDataForCreate, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        let response = await repository.updateReminder(reminderRequestDTO: reminderDataForCreate.modelToDTO(), reminderId: reminderId, userId: userId)
        
        switch response {
        case .success(let reminderDetailDTO):
            return .success(reminderDetailDTO.DTOToModel())
        case .failure(let error):
            return .failure(error)
        }
    }
    func deleteReminder(reminderId: Int, userId: String) async -> Result<Void, NetworkError> {
        let response = await repository.deleteReminder(reminderId: reminderId, userId: userId)
        
        switch response {
        case .success():
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    func updateReminderActivation(isActive: Bool, reminderId: Int, userId: String) async -> Result<ReminderDetailData, NetworkError> {
        let response = await repository.updateReminderActivation(isActive: isActive, reminderId: reminderId, userId: userId)
        
        switch response {
        case .success(let reminderDetailDTO):
            return .success(reminderDetailDTO.DTOToModel())
        case .failure(let error):
            return .failure(error)
        }
    }
}
