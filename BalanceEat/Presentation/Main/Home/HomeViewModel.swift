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
    private let dietUseCase: DietUseCaseProtocol
    
    let userResponseRelay = BehaviorRelay<UserData?>(value: nil)
    let dietResponseRelay = BehaviorRelay<DailyDietResponseDTO?>(value: nil)
    
    init(userUseCase: UserUseCaseProtocol, dietUseCase: DietUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.dietUseCase = dietUseCase
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
    
    func getDailyDiet() async {
        let getDailyDietResponse = await dietUseCase.getDailyDiet(date: Date())
        
        switch getDailyDietResponse {
        case .success(let dailyDiet):
            print("일일 식단 정보: \(dailyDiet)")
            dietResponseRelay.accept(dailyDiet)
        case .failure(let failure):
            print("일일 식단 정보 불러오기 실패: \(failure.localizedDescription)")
        }
    }
}
