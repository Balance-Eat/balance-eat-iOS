//
//  StatsRepository.swift
//  BalanceEat
//
//  Created by 김견 on 10/21/25.
//

import Foundation

struct StatsRepository: StatsRepositoryProtocol {
    private let apiClient = APIClient.shared
    
    func getStats(period: Period, userId: String) async -> Result<[StatsResponseDTO], NetworkError> {
        let endPoint = StatsEndPoints.getStats(period: period, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<[StatsResponseDTO]>.self
        )
        
        switch result {
        case .success(let response):
            print("get stats success \(response)")
            return .success(response.data)
        case .failure(let error):
            print("get stats failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
