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
    }
}
