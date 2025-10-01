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
            errorMessageRelay.accept("사용자 정보 불러오기 실패: \(failure.localizedDescription)")
            loadingRelay.accept(false)
        }
    }
    
    private func getUserUUID() -> String {
        let getUserUUIDResponse = userUseCase.getUserUUID()
        
        switch getUserUUIDResponse {
        case .success(let uuid):
            return uuid
        case .failure(let failure):
            errorMessageRelay.accept("UUID 불러오기 실패: \(failure.localizedDescription)")
            return ""
        }
        
    }
}
