//
//  ChartViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 10/12/25.
//

import Foundation
import RxSwift
import RxCocoa

final class ChartViewModel: BaseViewModel {
    private let userUseCase: UserUseCaseProtocol
    private let statsUseCase: StatsUseCaseProtocol
    
    var cachedStats: [String: [StatsData]] = [:]
    let currentStatsRelay: BehaviorRelay<[StatsData]> = .init(value: [])
    let userDataRelay: BehaviorRelay<UserData?> = .init(value: nil)
    
    init(userUseCase: UserUseCaseProtocol, statsUseCase: StatsUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.statsUseCase = statsUseCase
    }
    
    private func getUserId() -> String {
        switch userUseCase.getUserId() {
        case .success(let userId):
            return String(userId)
        case .failure(let failure):
            handleError(failure, prefix: "유저 아이디 불러오기 실패: ")
            return ""
        }
    }
    
    func getUser() async {
        let uuid = getUserUUID()
        
        loadingRelay.accept(true)
        let getUserResponse = await userUseCase.getUser(uuid: uuid)
        
        switch getUserResponse {
        case .success(let user):
            print("사용자 정보: \(user)")
            userDataRelay.accept(user)
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
    
    func getStats(period: Period) async {
        loadingRelay.accept(true)
        let response = await statsUseCase.getStats(period: period, userId: getUserId())
        
        switch response {
        case .success(let statsDatas):
            cachedStats[period.rawValue, default: []] = statsDatas
            currentStatsRelay.accept(statsDatas)
            
            loadingRelay.accept(false)
        case .failure(let failure):
            loadingRelay.accept(false)
            handleError(failure, prefix: "통계 정보 불러오기 실패: ")
        }
        
        
        
        
//        currentStatsRelay.accept(
//            [
//                StatsData(
//                    type: .daily,
//                    date: "2025-08-01",
//                    totalCalories: 2000,
//                    totalCarbohydrates: 250,
//                    totalProtein: 100,
//                    totalFat: 50,
//                    weight: 90
//                ),
//                StatsData(
//                    type: .daily,
//                    date: "2025-08-02",
//                    totalCalories: 2100,
//                    totalCarbohydrates: 250,
//                    totalProtein: 120,
//                    totalFat: 50,
//                    weight: 90
//                ),
//                StatsData(
//                    type: .daily,
//                    date: "2025-08-03",
//                    totalCalories: 2300,
//                    totalCarbohydrates: 230,
//                    totalProtein: 220,
//                    totalFat: 70,
//                    weight: 95
//                ),
//                StatsData(
//                    type: .daily,
//                    date: "2025-08-04",
//                    totalCalories: 2600,
//                    totalCarbohydrates: 280,
//                    totalProtein: 100,
//                    totalFat: 60,
//                    weight: 100
//                ),
//                StatsData(
//                    type: .daily,
//                    date: "2025-08-05",
//                    totalCalories: 2100,
//                    totalCarbohydrates: 210,
//                    totalProtein: 50,
//                    totalFat: 50,
//                    weight: 98
//                ),
//                StatsData(
//                    type: .daily,
//                    date: "2025-08-06",
//                    totalCalories: 2450,
//                    totalCarbohydrates: 240,
//                    totalProtein: 80,
//                    totalFat: 90,
//                    weight: 91
//                ),
//                StatsData(
//                    type: .daily,
//                    date: "2025-08-07",
//                    totalCalories: 2760,
//                    totalCarbohydrates: 260,
//                    totalProtein: 135,
//                    totalFat: 239,
//                    weight: 94
//                )
//            ]
//        )
    }
}
