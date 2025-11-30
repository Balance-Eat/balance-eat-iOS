//
//  MenuViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 8/31/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MenuViewModel: BaseViewModel {
    private let userUseCase: UserUseCaseProtocol
    private let notificationUseCase: NotificationUseCaseProtocol
    
    let userRelay = BehaviorRelay<UserData?>(value: nil)
    let updateUserResultRelay = PublishRelay<Bool>()
    
    let notificationRelay = BehaviorRelay<NotificationData?>(value: nil)
    
    
    init(userUseCase: UserUseCaseProtocol, notificationUseCase: NotificationUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.notificationUseCase = notificationUseCase
    }
    
    func getUser() async {
        let uuid = getUserUUID()
        
        loadingRelay.accept(true)
        
        let getUserResponse = await userUseCase.getUser(uuid: uuid)
        
        switch getUserResponse {
        case .success(let user):
            print("사용자 정보: \(user)")
            userRelay.accept(user)
            loadingRelay.accept(false)
        case .failure(let failure):
            toastMessageRelay.accept("사용자 정보 불러오기 실패: \(failure.localizedDescription)")
            loadingRelay.accept(false)
        }
    }
    
    private func getUserUUID() -> String {
        let getUserUUIDResponse = userUseCase.getUserUUID()
        
        switch getUserUUIDResponse {
        case .success(let uuid):
            return uuid
        case .failure(let failure):
            toastMessageRelay.accept("UUID 불러오기 실패: \(failure.localizedDescription)")
            return ""
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
    
    func getNotificationCurrentDevice(userId: String, agentId: String) async {
        loadingRelay.accept(true)
        
        let getNotificationCurrentDevice = await notificationUseCase.getCurrentDevice(userId: userId, agentId: agentId)
        
        switch getNotificationCurrentDevice {
        case .success(let notificationData):
            notificationRelay.accept(notificationData)
            loadingRelay.accept(false)
        case .failure(let failure):
            toastMessageRelay.accept("알림 정보 불러오기 실패: \(failure.localizedDescription)")
            loadingRelay.accept(false)
        }
    }
    
    func updateNotificationActivation(isActive: Bool, deviceId: Int, userId: String) async {
        let updateNotificationActivation = await notificationUseCase.updateActivation(isActive: isActive, deviceId: deviceId, userId: userId)
        
        switch updateNotificationActivation {
        case .success:
            break
        case .failure(let failure):
            toastMessageRelay.accept("알림 정보 업데이트 실패: \(failure.localizedDescription)")
        }
    }
}
