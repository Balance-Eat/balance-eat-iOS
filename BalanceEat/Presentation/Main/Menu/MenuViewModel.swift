//
//  MenuViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 8/31/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MenuViewModel {
    private let userUseCase: UserUseCaseProtocol
    
    let loadingRelay = BehaviorRelay<Bool>(value: false)
    let errorRelay = PublishRelay<String>()
    
    let userRelay = BehaviorRelay<UserData?>(value: nil)
    let updateUserResultRelay = PublishRelay<Bool>()
    
    
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
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
            print("사용자 정보 불러오기 실패: \(failure.localizedDescription)")
            errorRelay.accept(failure.localizedDescription)
            loadingRelay.accept(false)
        }
    }
    
    private func getUserUUID() -> String {
        let getUserUUIDResponse = userUseCase.getUserUUID()
        
        switch getUserUUIDResponse {
        case .success(let uuid):
            return uuid
        case .failure(let failure):
            print("UUID 불러오기 실패: \(failure.localizedDescription)")
            errorRelay.accept(failure.localizedDescription)
            return ""
        }
        
    }
}
