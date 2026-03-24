//
//  StatsRepository.swift
//  BalanceEat
//
//  Created by 김견 on 10/21/25.
//

import Foundation

struct DefaultStatsRepository: StatsRepository {
    private let apiClient: any APIClientProtocol

    init(apiClient: any APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    func getStats(period: Period, userId: String) async -> Result<[StatsData], NetworkError> {
        let endPoint = StatsEndPoints.getStats(period: period, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<[StatsResponseDTO]>.self
        )

        switch result {
        case .success(let response): return .success(response.data.map { $0.DTOToModel() })
        case .failure(let error): return .failure(error)
        }
    }
}
