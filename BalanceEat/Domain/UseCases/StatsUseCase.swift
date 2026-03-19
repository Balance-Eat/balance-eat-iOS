//
//  StatsUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 10/21/25.
//

import Foundation

protocol StatsUseCaseProtocol {
    func getStats(period: Period, userId: String) async -> Result<[StatsData], NetworkError>
}

struct StatsUseCase: StatsUseCaseProtocol {
    private let repository: StatsRepositoryProtocol

    init(repository: StatsRepositoryProtocol) {
        self.repository = repository
    }

    func getStats(period: Period, userId: String) async -> Result<[StatsData], NetworkError> {
        await repository.getStats(period: period, userId: userId)
    }
}
