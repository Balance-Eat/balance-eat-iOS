//
//  StatsRepositoryProtocol.swift
//  BalanceEat
//
//  Created by 김견 on 10/21/25.
//

import Foundation

protocol StatsRepository {
    func getStats(period: Period, userId: String) async -> Result<[StatsData], NetworkError>
}
