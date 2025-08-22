//
//  DietRepository.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//

import Foundation

struct DietRepository: DietRepositoryProtocol {
    private let apiClient = APIClient.shared
    
    func getDailyDiet(date: Date) async -> Result<DailyDietResponseDTO, NetworkError> {
        let endpoint = DietEndPoints.daily(date: date.toString())
        let result = await apiClient.request(
            endpoint: endpoint,
            responseType: BaseResponse<DailyDietResponseDTO>.self
        )
        
        switch result {
        case .success(let response):
            print("get daily diet success \(response)")
            return .success(response.data)
        case .failure(let error):
            print("get daily diet failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    
}
