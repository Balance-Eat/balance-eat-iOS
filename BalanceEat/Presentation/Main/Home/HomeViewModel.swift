//
//  HomeViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 8/21/25.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel: BaseViewModel {
    private let userUseCase: UserUseCaseProtocol
    private let dietUseCase: DietUseCaseProtocol
    
    let userResponseRelay = BehaviorRelay<UserData?>(value: nil)
    let dietResponseRelay = BehaviorRelay<[DietData]?>(value: nil)
    
    init(userUseCase: UserUseCaseProtocol, dietUseCase: DietUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.dietUseCase = dietUseCase
    }
    
    func getUser() async {
        let uuid = getUserUUID()
        
        loadingRelay.accept(true)
        let getUserResponse = await userUseCase.getUser(uuid: uuid)
        
        switch getUserResponse {
        case .success(let user):
            print("사용자 정보: \(user)")
            userResponseRelay.accept(user)
            saveUserId(user.id)
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
    
    private func saveUserId(_ userId: Int) {
        if case .failure(let error) = userUseCase.saveUserId(Int64(userId)) {
            errorMessageRelay.accept("userId 저장 실패: \(error.localizedDescription)")
        }
    }
    
    func getDailyDiet() async {
        guard let userId = userResponseRelay.value?.id else {
            return
        }
        
        loadingRelay.accept(true)
        let getDailyDietResponse = await dietUseCase.getDailyDiet(date: Date(), userId: String(userId))
        
        switch getDailyDietResponse {
        case .success(let dietDTOs):
            print("일일 식단 정보: \(dietDTOs)")
            let dietDataList: [DietData] = dietDTOs.map { $0.toDietData() }
            dietResponseRelay.accept(dietDataList)
            loadingRelay.accept(false)
        case .failure(let failure):
            errorMessageRelay.accept("일일 식단 정보 불러오기 실패: \(failure.localizedDescription)")
            loadingRelay.accept(false)
        }
    }
}
