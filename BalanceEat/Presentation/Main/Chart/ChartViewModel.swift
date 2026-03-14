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
        super.init()
    }
    
    private func getUserId() -> String? {
        switch userUseCase.getUserId() {
        case .success(let userId):
            return String(userId)
        case .failure(let failure):
            toastMessageRelay.accept("유저 아이디 불러오기 실패: \(failure.description)")
            return nil
        }
    }

    @MainActor
    func getUser() async {
        guard let uuid = getUserUUID() else { return }

        loadingRelay.accept(true)
        let getUserResponse = await userUseCase.getUser(uuid: uuid)
        
        switch getUserResponse {
        case .success(let user):
            userDataRelay.accept(user)
            loadingRelay.accept(false)
        case .failure(let failure):
            toastMessageRelay.accept("사용자 정보 불러오기 실패: \(failure.description)")
            loadingRelay.accept(false)
        }
    }
    
    private func getUserUUID() -> String? {
        switch userUseCase.getUserUUID() {
        case .success(let uuid):
            return uuid
        case .failure(let failure):
            toastMessageRelay.accept("UUID 불러오기 실패: \(failure.description)")
            return nil
        }
    }
    
    @MainActor
    func getStats(period: Period) async {
        guard let userId = getUserId() else { return }

        loadingRelay.accept(true)
        let response = await statsUseCase.getStats(period: period, userId: userId)

        switch response {
        case .success(let statsDatas):
            cachedStats[period.rawValue, default: []] = statsDatas
            currentStatsRelay.accept(statsDatas)
            loadingRelay.accept(false)
        case .failure(let failure):
            loadingRelay.accept(false)
            toastMessageRelay.accept("통계 정보 불러오기 실패: \(failure.description)")
        }
    }
}
