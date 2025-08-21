//
//  HomeViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 8/21/25.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel {
    private let userUseCase: UserUseCaseProtocol
    let userResponseRelay = BehaviorRelay<UserResponseDTO?>(value: nil)
    
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
    }
    
    func getUser() async {
        let uuid = getUserUUID()
        
        let getUserResponse = await userUseCase.getUser(uuid: uuid)
        
        switch getUserResponse {
        case .success(let user):
            print("사용자 정보: \(user)")
            userResponseRelay.accept(user) 
        case .failure(let failure):
            print("사용자 정보 불러오기 실패: \(failure.localizedDescription)")
        }
    }
    
    private func getUserUUID() -> String {
        let getUserUUIDResponse = userUseCase.getUserUUID()
        
        switch getUserUUIDResponse {
        case .success(let uuid):
            return uuid
        case .failure(let failure):
            print("UUID 불러오기 실패: \(failure.localizedDescription)")
            return ""
        }
        
    }
}
