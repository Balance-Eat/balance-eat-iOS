//
//  SetRemindNotiViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 11/30/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SetRemindNotiViewModel: BaseViewModel {
    private let notificationUseCase: NotificationUseCaseProtocol
    private let reminderUseCase: ReminderUseCaseProtocol
    private let userUseCase: UserUseCaseProtocol
    
    var currentPage: Int = 0
    var totalPage: Int = 0
    var isLastPage: Bool { currentPage == totalPage }
    let size: Int = 10
    
    let reminderListRelay: BehaviorRelay<[ReminderData]> = .init(value: [])
    let reminderDetailRelay: BehaviorRelay<ReminderDetailData?> = .init(value: nil)
    
    init(notificationUseCase: NotificationUseCaseProtocol, reminderUseCase: ReminderUseCaseProtocol, userUseCase: UserUseCaseProtocol) {
        self.notificationUseCase = notificationUseCase
        self.reminderUseCase = reminderUseCase
        self.userUseCase = userUseCase
        super.init()
    }
    
    func getReminderList() async {
        loadingRelay.accept(true)
        currentPage = 0
        
        let getReminderListResponse = await reminderUseCase.getReminderList(page: currentPage, size: size, userId: getUserId())
        
        switch getReminderListResponse {
        case .success(let reminderListData):
            print("리마인더 리스트 불러오기 성공: \(reminderListData)")
            loadingRelay.accept(false)
            reminderListRelay.accept(reminderListData.items)
            currentPage += 1
            totalPage = reminderListData.totalPages
        case .failure(let error):
            loadingRelay.accept(false)
            toastMessageRelay.accept(error.localizedDescription)
        }
    }
    
    func fetchReminderList() async {
        guard !isLastPage else { return }
        
        loadingRelay.accept(true)
        
        let getReminderListResponse = await reminderUseCase.getReminderList(page: currentPage, size: size, userId: getUserId())
        
        switch getReminderListResponse {
        case .success(let reminderListData):
            print("리마인더 리스트 추가 불러오기 성공")
            loadingRelay.accept(false)
            reminderListRelay.accept(reminderListRelay.value + reminderListData.items)
            currentPage += 1
        case .failure(let error):
            loadingRelay.accept(false)
            toastMessageRelay.accept(error.localizedDescription)
        }
    }
    
    func createReminder(reminderDataForCreate: ReminderDataForCreate) async {
        loadingRelay.accept(true)
        
        let createReminderResponse = await reminderUseCase.createReminder(reminderDataForCreate: reminderDataForCreate, userId: getUserId())
        
        switch createReminderResponse {
        case .success(let reminderDetailData):
            print("리마인더 생성 성공")
            loadingRelay.accept(false)
            
            let reminderData = ReminderData(
                id: reminderDetailData.id,
                content: reminderDetailData.content,
                sendTime: reminderDetailData.sendTime,
                isActive: reminderDetailData.isActive,
                dayOfWeeks: reminderDetailData.dayOfWeeks
            )
            var currentReminderList = reminderListRelay.value
            currentReminderList.append(reminderData)
            reminderListRelay.accept(currentReminderList)
        case .failure(let error):
            loadingRelay.accept(false)
            toastMessageRelay.accept(error.localizedDescription)
        }
    }
    
    func getReminderDetail(reminderId: Int) async {
        loadingRelay.accept(true)
        
        let reminderDetailResponse = await reminderUseCase.getReminderDetail(reminderId: reminderId, userId: getUserId())
        
        switch reminderDetailResponse {
        case .success(let reminderDetailData):
            print("리마인더 상세 조회 성공")
            loadingRelay.accept(false)
            reminderDetailRelay.accept(reminderDetailData)
        case .failure(let error):
            loadingRelay.accept(false)
            toastMessageRelay.accept(error.localizedDescription)
        }
    }
    
    func updateReminder(reminderDataForCreate: ReminderDataForCreate, reminderId: Int) async {
        loadingRelay.accept(true)
        
        let reminderUpdateResponse = await reminderUseCase.updateReminder(reminderDataForCreate: reminderDataForCreate, reminderId: reminderId, userId: getUserId())
        
        switch reminderUpdateResponse {
        case .success(let reminderDetailData):
            print("리마인더 수정 성공")
            loadingRelay.accept(false)
            var currentReminderList = reminderListRelay.value
            if let index = currentReminderList.firstIndex(where: { $0.id == reminderId }) {
                let updatedReminder = ReminderData(
                    id: reminderDetailData.id,
                    content: reminderDetailData.content,
                    sendTime: reminderDetailData.sendTime,
                    isActive: reminderDetailData.isActive,
                    dayOfWeeks: reminderDetailData.dayOfWeeks
                )
                currentReminderList[index] = updatedReminder
                reminderListRelay.accept(currentReminderList)
            }
            
        case .failure(let error):
            loadingRelay.accept(false)
            toastMessageRelay.accept(error.localizedDescription)
        }
    }
    
    func deleteReminder(reminderId: Int) async {
        loadingRelay.accept(true)
        
        let reminderDeleteResponse = await reminderUseCase.deleteReminder(reminderId: reminderId, userId: getUserId())
        
        switch reminderDeleteResponse {
        case .success(()):
            print("리마인더 삭제 성공")
            loadingRelay.accept(false)
            var currentReminderList = reminderListRelay.value
            if let index = currentReminderList.firstIndex(where: { $0.id == reminderId }) {
                currentReminderList.remove(at: index)
                reminderListRelay.accept(currentReminderList)
            }
        case .failure(let error):
            loadingRelay.accept(false)
            toastMessageRelay.accept(error.localizedDescription)
        }
    }
    
    func updateReminderActivation(isActive: Bool, reminderId: Int) async {
        loadingRelay.accept(true)
        
        let reminderUpdateActivationResponse = await reminderUseCase.updateReminderActivation(isActive: isActive, reminderId: reminderId, userId: getUserId())
        
        switch reminderUpdateActivationResponse {
        case .success(_):
            print("리마인더 활성화 변경 성공")
            loadingRelay.accept(false)
        case .failure(let error):
            loadingRelay.accept(false)
            toastMessageRelay.accept(error.localizedDescription)
        }
    }
    
    func getUserId() -> String {
        let userIdResponse = userUseCase.getUserId()
        
        switch userIdResponse {
        case .success(let userId):
            return String(userId)
        case .failure(let failure):
            toastMessageRelay.accept(failure.localizedDescription)
            return ""
        }
    }
}
