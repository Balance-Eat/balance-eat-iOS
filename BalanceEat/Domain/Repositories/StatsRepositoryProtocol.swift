//
//  StatsRepositoryProtocol.swift
//  BalanceEat
//
//  Created by 김견 on 10/21/25.
//

import Foundation

protocol StatsRepositoryProtocol {
    func getStats(period: Period, userId: String) async -> Result<[StatsResponseDTO], NetworkError>
}
